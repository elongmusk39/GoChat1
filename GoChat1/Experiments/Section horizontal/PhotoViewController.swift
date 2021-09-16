//
//  PhotoViewController.swift
//  GoChat
//
//  Created by Long Nguyen on 8/5/21.
//

import UIKit
import Firebase
import SDWebImage

private let CollectionCellID = "CollectionCellID"
private let searchCellID = "searchCellID"


class PhotoViewController: UIViewController {
    
    private var userMail = Auth.auth().currentUser?.email ?? "no mail"
    private var sectionPhotoArray = [Picture]()
    var bigPhotoArray = [Picture]()
    
    private var btnDimension: CGFloat = 32
    private var numberOfSection: Int = 1
    private var sectionIndex: Int = 1
    private let NoOfImage: Int = 9
    private var isEditActivated = false
    var justDelete = false
    
    private var justDeleteItem: NSObjectProtocol?
    private var refetchPhotoObserver: NSObjectProtocol?
    
    private var chosenPhotoArray = [Picture]()
    private var chosenIndexArray = [Int]()
    
    
//MARK: - Components
    
    private let tableView = UITableView()
    
    private let numberOfImgLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Total: ... photos"
        lb.textColor = .green
        lb.textAlignment = .center
        lb.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        return lb
    }()
    
    private let noImageLabel: UILabel = {
        let lb = UILabel()
        lb.text = "No Image to show."
        lb.textColor = .gray
        lb.numberOfLines = .zero
        lb.textAlignment = .center
        lb.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        
        return lb
    }()
    
    //"lazy var" since we gotta register the cell after loading
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .black
        cv.register(PhotoCell.self, forCellWithReuseIdentifier: CollectionCellID)
        
        return cv
    }()
    
    
    //let's deal with the SearchBar
    private let searchBarController = UISearchController(searchResultsController: nil)
    private var filteredPhotos = [Picture]()
    //this var is dynamics, which changes its value all the time depending on the searchBar's behavior
    private var isSearchMode: Bool {
        return searchBarController.isActive && !searchBarController.searchBar.text!.isEmpty
        //returns true only if searchBar is active and searchText is NOT empty
    }
    
//MARK: - Bottom Edit
    
    private let bottomCover: UIView = {
        let vw = UIView()
        vw.backgroundColor = .black
        return vw
    }()
    
    private let bottomView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .green
        vw.alpha = 0
        return vw
    }()
    
    private let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "arrowshape.turn.up.forward"), for: .normal)
        btn.tintColor = .red
        btn.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(sendTo), for: .touchUpInside)
        
        return btn
    }()
    
    private let deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "trash"), for: .normal)
        btn.tintColor = .red
        btn.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(deletePhoto), for: .touchUpInside)
        
        return btn
    }()
    
    private let numberLabel: UILabel = {
        let lb = UILabel()
        lb.text = "2 / 70"
        lb.textColor = .white
        lb.textAlignment = .center
        lb.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        
        return lb
    }()
    
    
//MARK: - Bottom section Page
    
    private let bottomSectionView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .black
        return vw
    }()
    
    private let forwardButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "arrowtriangle.right"), for: .normal)
        btn.tintColor = .green
        btn.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(forwardPage), for: .touchUpInside)
        
        return btn
    }()
    
    private let backwardButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "arrowtriangle.backward"), for: .normal)
        btn.tintColor = .green
        btn.contentMode = .scaleAspectFit
        btn.alpha = 0.47
        btn.isUserInteractionEnabled = false //when this page initially load, backwardButton cannot be enabled
        btn.addTarget(self, action: #selector(backwardPage), for: .touchUpInside)
        
        return btn
    }()
    
    private let sectionLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Loading...."
        lb.textColor = .green
        lb.textAlignment = .center
        lb.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        return lb
    }()
    
    
//MARK: - View Scenes
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        fetchPhotoInfo()
        configureNavAndSearchBar()
        configureUIAndCollView()
        showNoImage()
        longPressStuff()
        protocolVC()
        swipeGesture()
        
    }
    
    
//MARK: - Configure stuff
    
    private func configureNavAndSearchBar() {
        configureNavigationBar(title: "Library", preferLargeTitle: false, backgroundColor: .black, buttonColor: .green, interface: .dark)
        showNavBarButtons()
        configureSearchBarController()
    }
    
    private func configureUIAndCollView() {
        
        view.addSubview(numberOfImgLabel)
        numberOfImgLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 24)
        
        view.addSubview(collectionView)
        collectionView.anchor(top: numberOfImgLabel.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 4, paddingBottom: 44)
        
        view.addSubview(noImageLabel)
        noImageLabel.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 24, paddingRight: 24)
        noImageLabel.centerY(inView: view)
        
        //bottom section page stuff
        view.addSubview(bottomCover)
        bottomCover.anchor(top: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        view.addSubview(bottomSectionView)
        bottomSectionView.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, height: 44)
        
        let stackSection = UIStackView(arrangedSubviews: [backwardButton, sectionLabel, forwardButton])
        forwardButton.setDimensions(height: btnDimension-2, width: btnDimension-2)
        backwardButton.setDimensions(height: btnDimension-2, width: btnDimension-2)
        stackSection.axis = .horizontal
        stackSection.alignment = .center
        bottomSectionView.addSubview(stackSection)
        stackSection.anchor(top: bottomSectionView.topAnchor, left: bottomSectionView.leftAnchor, bottom: bottomSectionView.bottomAnchor, right: bottomSectionView.rightAnchor, paddingLeft: 12, paddingRight: 12)
        
        //bottom edit stuff
        view.addSubview(bottomView)
        bottomView.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, height: 50)
        bottomView.isHidden = true
        
        let stack = UIStackView(arrangedSubviews: [deleteButton, numberLabel, sendButton])
        sendButton.setDimensions(height: btnDimension, width: btnDimension)
        deleteButton.setDimensions(height: btnDimension, width: btnDimension)
        stack.axis = .horizontal
        stack.alignment = .center
        bottomView.addSubview(stack)
        stack.anchor(top: bottomView.topAnchor, left: bottomView.leftAnchor, bottom: bottomView.bottomAnchor, right: bottomView.rightAnchor, paddingLeft: 12, paddingRight: 12)
        
    }
    
//MARK: - TableView Search
    
    private func configureTableViewAndHideCollView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .black
        
        view.addSubview(tableView)
        tableView.fillSuperview()
        tableView.alpha = 0
        
        //for default cell, use  "UITableViewCell.self"
        tableView.register(SearchPhotoCell.self, forCellReuseIdentifier: searchCellID)
        tableView.rowHeight = 88
        
        //now for the animation
        UIView.animate(withDuration: 0.1) {
            self.collectionView.alpha = 0
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.tableView.alpha = 1
            }
        }

    }
    
    private func hideTableAndShowCollVIew() {
        UIView.animate(withDuration: 0.1) {
            self.tableView.alpha = 0
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.tableView.removeFromSuperview()
                self.collectionView.alpha = 1
            }
        }
    }
    
//MARK: - Search Bar
    
    func configureSearchBarController() {
        searchBarController.obscuresBackgroundDuringPresentation = false
        searchBarController.hidesNavigationBarDuringPresentation = false
        searchBarController.searchBar.placeholder = "Search for address or date.."
        searchBarController.searchBar.barStyle = UIBarStyle.black
        navigationItem.searchController = searchBarController //got affect by the UIInterfaceStyle of the navBar
        definesPresentationContext = false
        
        searchBarController.searchBar.delegate = self
        searchBarController.searchResultsUpdater = self
    }
    
//MARK: - Protocols
    
    func protocolVC() {
        //protocol from PhotoArrayVC
        justDeleteItem = NotificationCenter.default.addObserver(forName: .deleteItem, object: nil, queue: .main) { [weak self] _ in
            
            print("DEBUG-PhotoVC: protocol from PhotoArrayVC, re-fetching..")
            guard let strongSelf = self else { return }
            strongSelf.dismissPhotoVC()
        }
    }
    
    deinit {
        if let observer1 = justDeleteItem {
            NotificationCenter.default.removeObserver(observer1)
        }
    }
    
//MARK: - Actions
    
    private func swipeGesture() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissPhotoVC))
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(forwardPage))
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(backwardPage))
        swipeDown.direction = .down
        swipeLeft.direction = .left
        swipeRight.direction = .right
        collectionView.addGestureRecognizer(swipeDown)
        collectionView.addGestureRecognizer(swipeLeft)
        collectionView.addGestureRecognizer(swipeRight)
    }
    
    private func showNoImage() {
        if bigPhotoArray.count == 0 {
            noImageLabel.isHidden = false
        } else {
            noImageLabel.isHidden = true
        }
    }
    
    @objc func dismissPhotoVC() {
        dismiss(animated: true, completion: nil)
    }
    
    private func hideNavBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .done, target: self, action: #selector(dismissPhotoVC))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: .done, target: self, action: #selector(editImages))
    }
    
    private func showNavBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .done, target: self, action: #selector(dismissPhotoVC))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(editImages))
    }
    
    private func deleteAnInfo(timeTaken: String) {
        showLoadingView(true)
        Firestore.firestore().collection("users").document(self.userMail).collection("library").document(timeTaken).delete { error in
            
            if let e = error?.localizedDescription {
                self.showLoadingView(false, message: "Deleting..")
                self.alert(error: e, buttonNote: "Try again")
                return
            }
            self.showLoadingView(false)
            self.collectionView.reloadData()
        }
    }
    
    private func deleteNonSensePhoto() {
        for idx in 0...bigPhotoArray.count-1 {
            if bigPhotoArray[idx].imageUrl == "no url" {
                deleteAnInfo(timeTaken: bigPhotoArray[idx].timestamp)
            }
        }
    }
    
    private func checkShowUpFromDeletion() {
        if justDelete == true {
            if sectionScrollAfterDeletion == 1 {
                print("DEBUG-PhotoVC: delete page 1, no scroll here...")
            }
            else if numberOfSection < sectionScrollAfterDeletion {
                print("DEBUG-PhotoVC: scroll to page \(sectionScrollAfterDeletion)")
                //minus 1 since the sectionIndex starts at 1 (default to fetch 1st page)
                for _ in 1...sectionScrollAfterDeletion-2 {
                    forwardPage()
                }
            } else {
                print("DEBUG-PhotoVC: scroll to page \(sectionScrollAfterDeletion)")
                //minus 1 since the sectionIndex starts at 1 (default to fetch 1st page)
                for _ in 1...sectionScrollAfterDeletion-1 {
                    forwardPage()
                }
            }
        } else {
            print("DEBUG-PhotoVC: nothing get deleted...")
        }
    }
    
    private func fetchPhotoInfo() {
        showLoadingView(true, message: "Loading...")
        print("DEBUG-PhotoVC: fetching images big array...")
        
        FetchingStuff.fetchPhotos(email: userMail) { pictureArray in
            self.bigPhotoArray = pictureArray
            self.showNoImage()
            self.numberOfImgLabel.text = "Total: \(pictureArray.count) photos"
            self.defineSectionPhoto()
            self.collectionView.reloadData() //recall all the collectionView extension
            self.checkShowUpFromDeletion()
            self.showLoadingView(false, message: "Loading...")
        }
    }
    
//MARK: - Section paging
    
    private func defineSectionPhoto() {
        if bigPhotoArray.count > NoOfImage {
            let a = Double(bigPhotoArray.count)/Double(NoOfImage)
            numberOfSection = Int(a.rounded(.up))
            sectionLabel.text = "1 / \(numberOfSection)"
            print("DEBUG-PhotoVC: we have \(numberOfSection) sections")
        } else {
            numberOfSection = 1
            sectionLabel.text = "Page 1"
            forwardButton.isHidden = true
            backwardButton.isHidden = true
            print("DEBUG-PhotoVC: we have less than 20 img")
        }
        assignSectionArray()
    }
    
    private func assignSectionArray() {
        let firstIdx = (sectionIndex-1)*NoOfImage
        let secondFullIdx = firstIdx + NoOfImage - 1
        
        let lastNo = bigPhotoArray.count - (numberOfSection-1)*NoOfImage //number of img in the last page (in case the last page doesnt have enough 20 img)
        let lastPartialIdx = firstIdx + lastNo - 1
        
        
        if sectionIndex == numberOfSection {
            if lastNo == NoOfImage {
                for idx in firstIdx...secondFullIdx {
                    sectionPhotoArray.append(bigPhotoArray[idx])
                }
            } else {
                for idx in firstIdx...lastPartialIdx {
                    sectionPhotoArray.append(bigPhotoArray[idx])
                }
            }
        } else {
            for idx in firstIdx...secondFullIdx {
                sectionPhotoArray.append(bigPhotoArray[idx])
            }
        }
    }
    
    
    @objc func forwardPage() {
        animationChangingPage()
        //let's check current section page
        if sectionIndex == numberOfSection {
            return //for swipe gesture
        }
        //now append new index from big array
        sectionPhotoArray.removeAll()
        sectionIndex = sectionIndex + 1
        sectionLabel.text = "\(sectionIndex) / \(numberOfSection)"
        assignSectionArray()
        
        backwardButton.isUserInteractionEnabled = true
        backwardButton.alpha = 1
        
        //now check the recently moved section page
        if sectionIndex == numberOfSection {
            forwardButton.isUserInteractionEnabled = false
            forwardButton.alpha = 0.47
        }
        collectionView.reloadData()
    }
    
    @objc func backwardPage() {
        animationChangingPage()
        if sectionIndex == 1 {
            return //for the swipe gesture
        }
        sectionPhotoArray.removeAll()
        sectionIndex = sectionIndex-1
        sectionLabel.text = "\(sectionIndex) / \(numberOfSection)"
        assignSectionArray()
        
        forwardButton.isUserInteractionEnabled = true
        forwardButton.alpha = 1
        if sectionIndex == 1 {
            backwardButton.alpha = 0.47
            backwardButton.isUserInteractionEnabled = false
        }
        collectionView.reloadData()
    }
    
    private func animationChangingPage() {
        UIView.animate(withDuration: 0.2) {
            self.collectionView.alpha = 0
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.collectionView.alpha = 1
            }
        }
    }
    
//MARK: - Edit feature
    
    private func configureEditFeature(alphaB: CGFloat, alphaS: CGFloat, alphaP: CGFloat, titleNew: String, isEdited: Bool) {
        
        navigationItem.rightBarButtonItem?.title = titleNew
        searchBarController.searchBar.alpha = alphaS
        searchBarController.searchBar.isUserInteractionEnabled = !isEdited
        isEditActivated = isEdited
        bottomView.isHidden = !isEdited
        UIView.animate(withDuration: 0.3) {
            self.bottomSectionView.alpha = alphaP
            self.bottomView.alpha = alphaB
            self.numberLabel.text = "0 selected"
        }
        collectionView.reloadData() //recall all extensions of collectionView
    }
    
    @objc func editImages() {
        print("DEBUG-PhotoVC: edit btn tapped..")
        guard let titleBtn = navigationItem.rightBarButtonItem?.title else { return }
        if titleBtn == "Edit" {
            configureEditFeature(alphaB: 1, alphaS: 0.37, alphaP: 0, titleNew: "Done", isEdited: true)
            checkArrToSeeIfPictureChosen()
        } else if titleBtn == "Done" {
            chosenPhotoArray.removeAll()
            chosenIndexArray.removeAll()
            configureEditFeature(alphaB: 0, alphaS: 1, alphaP: 1, titleNew: "Edit", isEdited: false)
            bottomCover.backgroundColor = .black
        }
    }
    
    private func checkArrToSeeIfPictureChosen() {
        if chosenPhotoArray.count == 0 {
            bottomView.backgroundColor = .black
            bottomCover.backgroundColor = .black
            sendButton.alpha = 0
            deleteButton.alpha = 0
            numberLabel.alpha = 0.67
            numberLabel.textColor = .white
        } else {
            bottomView.backgroundColor = .green
            bottomCover.backgroundColor = .green
            sendButton.alpha = 1
            numberLabel.alpha = 1
            deleteButton.alpha = 1
            numberLabel.textColor = .red
        }
    }
    
    @objc func deletePhoto() {
        if chosenPhotoArray.count == 0 {
            alert(error: "Please pick a photo to delete.", buttonNote: "OK")
        } else {
            print("DEBUG-PhotoVC: deleting array has \(chosenPhotoArray.count) items")
            chosenDeleteAlert()
        }
    }
    
    private func chosenDeleteAlert() {
        let alert = UIAlertController (title: "Deleted \(chosenPhotoArray.count) photos?", message: "These photos will be permanently deleted from the server.", preferredStyle: .alert)
        let cancel  = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let delete = UIAlertAction (title: "Delete", style: .destructive) { delete in
            self.chosenNowDelete()
        }
        
        alert.addAction(cancel)
        alert.addAction(delete)
        present(alert, animated: true, completion: nil)
    }
    
    private func chosenNowDelete() {
        for idx in 0...chosenPhotoArray.count-1 {
            let indexDelete = chosenIndexArray[idx]
            nowDelete(rowSectionNumber: indexDelete)
        }
        editImages()
    }
    
    @objc func sendTo() {
        
    }
    
//MARK: - longPress
    
    private func longPressStuff() {
        let longPressColl = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressColl(sender:)))
        collectionView.addGestureRecognizer(longPressColl)
    }
    
    @objc func handleLongPressColl(sender: UILongPressGestureRecognizer) {
        if isEditActivated {
            print("DEBUG-PhotoVC: editing in process..")
        } else {
            if sender.state == .began {
                let touchPoint = sender.location(in: collectionView)
                
                //we can see the index of the cell from this func
                if let index = collectionView.indexPathForItem(at: touchPoint) {
                    print("DEBUG-PhotoVC: chose long press row \(index.row)")
                    editImages()
                }
            }
        }
        
    }
    
//MARK: - Deletion
    
    private func deleteAlert(rowIndex: Int) {
        let alert = UIAlertController (title: "Deleted this photo?", message: "This photo will be permanently deleted from the server.", preferredStyle: .alert)
        let cancel  = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let delete = UIAlertAction (title: "Delete", style: .destructive) { delete in
            self.nowDelete(rowSectionNumber: rowIndex)
        }
        
        alert.addAction(cancel)
        alert.addAction(delete)
        present(alert, animated: true, completion: nil)
    }
    
    private func nowDelete(rowSectionNumber: Int) {
        print("DEBUG-PhotoVC: deletion \(rowSectionNumber) confirmed..")
        showLoadingView(true, message: "Deleting..")
        
        let timeTaken = sectionPhotoArray[rowSectionNumber].timestamp
        let nameStorage = "\(sectionPhotoArray[rowSectionNumber].timestamp)-\(sectionPhotoArray[rowSectionNumber].city)"
        
        let ref = Storage.storage().reference(withPath: "/library/\(userMail)/\(nameStorage)")
        ref.delete { error in
            if let e = error?.localizedDescription {
                self.alert(error: e, buttonNote: "Try Again")
                return
            }
            print("DEBUG-PhotoVC: done delete in storage, now in firestore..")
            
            Firestore.firestore().collection("users").document(self.userMail).collection("library").document(timeTaken).delete { error in
                
                if let e = error?.localizedDescription {
                    self.showLoadingView(false, message: "Deleting..")
                    self.alert(error: e, buttonNote: "Try again")
                    return
                }
                self.doneDeletion()
            }
        }
        
    }
    
    private func doneDeletion() {
        sectionScrollAfterDeletion = self.sectionIndex
        print("DEBUG-PhotoVC: sucessfully deleting item at \(sectionScrollAfterDeletion) page")
        self.dismiss(animated: true, completion: nil)
        //let's send the notification to CameraVC to re-show PhotoVC
        NotificationCenter.default.post(name: .deleteFromPhotoVC, object: nil)
    }
    
    
}

//MARK: - SearchBar Delegate
//this extension declares what happen when user clicks on the searchBar or the "cancel" button
//remember to write "searchBarController.searchBar.delegate = self"
extension PhotoViewController: UISearchBarDelegate {
    
    //this is what happens when searchBar is clicked
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        print("DEBUG-PhotoVC: SearchBar is active")
        configureTableViewAndHideCollView()
        hideNavBarButtons()
    }

    //what happens when cancel button is clicked
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true) //dismiss the keyboard
        searchBar.showsCancelButton = false
        searchBar.text = ""
        hideTableAndShowCollVIew()
        showNavBarButtons()
    }
    
    
}

//MARK: - SearchBar Result update
//remember to write "searchBarController.searchResultsUpdater = self"
extension PhotoViewController: UISearchResultsUpdating {
    
    //this func gets called whenever we type something in the search textBox
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchBarController.searchBar.text?.lowercased() else { return }
        print("DEBUG-PhotoVC: searchText is \(searchText)")
        //Set the filteredPhotos
        self.filteredPhotos = bigPhotoArray.filter({
            $0.date.lowercased().contains(searchText) || $0.country.lowercased().contains(searchText) || $0.county.lowercased().contains(searchText) || $0.city.lowercased().contains(searchText) || $0.state.lowercased().contains(searchText) || $0.streetName.lowercased().contains(searchText) || $0.streetNo.lowercased().contains(searchText)
        }) //keep in mind, this shit is CASE SENSITIVE, so we convert both the searchText and "date, country,..." to lowercased
        
        print("DEBUG-PhotoVC: we have \(filteredPhotos.count) filtered photos")
        self.tableView.reloadData()
    } //end of func
    
}

//MARK: - collectionView datasource

extension PhotoViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionPhotoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //configure and pass data to cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionCellID, for: indexPath) as! PhotoCell
        cell.photoInfo = sectionPhotoArray[indexPath.row]
//        cell.configureImage(url: sectionPhotoArray[indexPath.row].imageUrl)
        
        //now configure the other components
        cell.itemCell = indexPath.row
        cell.delegate = self //to make protocols work
        cell.isEditing = isEditActivated //frequently change in func "showEditFeature"
        cell.isPicked = false //set it all to false for "Edit" feature
        
        return cell
    }
    
}

//MARK: - Protocols and CollectionView Delegate
//we cannot use "indexPath.row" cuz we dont use func "didSelectItemAt", so we have to pass in the "time"
extension PhotoViewController: PhotoCellDelegate, UICollectionViewDelegate {

    func showBigPhotoArray(_ cell: PhotoCell, index: Int) {
        print("DEBUG-PhotoVC: photo index tapped at \(index)")
        let vc = PhotoArrayViewController(imgArray: sectionPhotoArray, indexValue: index)
        vc.userEmail = userMail
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    func showMapPhotoVC(_ cell: PhotoCell, time: String) {
        print("DEBUG-PhotoVC: map icon tapped")
        let vc = MapPhotoViewController(timeOfPhoto: time)
        vc.currentEmail = userMail
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    func chosenArray(_ cell: PhotoCell, append: Bool, index: Int) {
        if append {
            //append index
            let pickedItem = sectionPhotoArray[index]
            chosenPhotoArray.append(pickedItem)
            chosenIndexArray.append(index)
            checkArrToSeeIfPictureChosen()
            numberLabel.text = "\(chosenPhotoArray.count) selected"
        } else if append == false {
            //remove index
            var chosenIndex = 0 //give a default value
            for idx in 0...chosenIndexArray.count-1 {
                if chosenIndexArray[idx] == index { //which only happen once
                    chosenIndex = idx
                }
            } //use for-loop to figure out the chosenIndex
            chosenIndexArray.remove(at: chosenIndex)
            chosenPhotoArray.remove(at: chosenIndex)
            checkArrToSeeIfPictureChosen()
            numberLabel.text = "\(chosenPhotoArray.count) selected"
        }
    }
    
    
}

//MARK: - DelegateFlowlayout

extension PhotoViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    //spacing for row (horizontally) between items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    //spacing for collumn (vertically) between items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    //set size for each item
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = (view.frame.width-4) / 3
//        return CGSize(width: width, height: 1.3*width)
        
        let width = (view.frame.width-4) / 3
        return CGSize(width: width, height: 1.25*width)
    }
    
}

//MARK: - tableView Datasource

extension PhotoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchMode { //whenever user type something in
            return filteredPhotos.count > NoOfImage ? NoOfImage : filteredPhotos.count
        } else {
            return bigPhotoArray.count > NoOfImage ? NoOfImage : filteredPhotos.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: searchCellID, for: indexPath) as! SearchPhotoCell
        cell.photoInfo = isSearchMode ? filteredPhotos[indexPath.row] : bigPhotoArray[indexPath.row]
        
        return cell
    }
    
    
}

//MARK: - tableView Delegate
extension PhotoViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true) //unhightlight the cell tapped
        let time = isSearchMode ? filteredPhotos[indexPath.row].timestamp : bigPhotoArray[indexPath.row].timestamp
        
        print("DEBUG: time is \(time)")
        let vc = MapPhotoViewController(timeOfPhoto: time)
        vc.currentEmail = userMail
        vc.fromSearch = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
