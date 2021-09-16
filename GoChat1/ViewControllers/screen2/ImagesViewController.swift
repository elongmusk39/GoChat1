//
//  ImagesViewController.swift
//  GoChat
//
//  Created by Long Nguyen on 8/24/21.
//

import UIKit
import Firebase
import SDWebImage
import MapKit

private let CollectionCellID = "CollectionCellID"
private let searchCellID = "searchCellID"


class ImagesViewController: UIViewController {
    
    private var userMail = Auth.auth().currentUser?.email ?? "no mail"
//    private var sectionPhotoArray = [Picture]()
    var bigPhotoArray = [Picture]()
    private var sameLocationImgArray = [Picture]()
    private var sortLocationImgArray = [[Picture]]()
    
    private var simpleAddressArray = [String]()
    private var sortAdressArray = [String]()
    private var latArray = [CLLocationDegrees]()
    private var longArray = [CLLocationDegrees]()
    private var didSortAddress = false
    
    private var btnDimension: CGFloat = 32
    private let NoOfImage: Int = 9
    private var hideNoImgLabel = false
    
    private var justDeleteItem: NSObjectProtocol?
    private var refetchPhotoObserver: NSObjectProtocol?
    
    
//MARK: - Components
    
    private let tableView = UITableView()
    
    private let topRecentView = RecentView()
    
    private let locationLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Locations:"
        lb.textColor = .white
        lb.textAlignment = .center
        lb.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        
        return lb
    }()
    
    private let recentLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Recent:"
        lb.textColor = .white
        lb.textAlignment = .center
        lb.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        
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
        cv.register(ImageCellCustomize.self, forCellWithReuseIdentifier: CollectionCellID)
        
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
    
    
//MARK: - View Scenes
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        
        swipeGesture()
        fetchPhotoInfo()
        configureNavAndSearchBar()
        configureUIAndCollView()
        protocolVC()
        
    }
    
//MARK: - Configure stuff
    
    private func configureNavAndSearchBar() {
        configureNavigationBar(title: "Library", preferLargeTitle: false, backgroundColor: .black, buttonColor: .green, interface: .dark)
        showNavBarButtons()
        configureSearchBarController()
    }
    
    private func configureUIAndCollView() {
        view.addSubview(noImageLabel)
        noImageLabel.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 24, paddingRight: 24)
        noImageLabel.centerY(inView: view)
        
        //top components
        view.addSubview(recentLabel)
        recentLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 12, paddingLeft: 12)
        
        view.addSubview(topRecentView)
        topRecentView.anchor(top: recentLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 12, paddingLeft: 16, paddingRight: 16)
        topRecentView.delegate = self
        
        //bottom components
        view.addSubview(locationLabel)
        locationLabel.anchor(top: topRecentView.bottomAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 12)
        
        view.addSubview(collectionView)
        collectionView.anchor(top: locationLabel.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 12)
        collectionView.backgroundColor = .black
        
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
            strongSelf.emptyArrays()
            strongSelf.fetchPhotoInfo()
            strongSelf.topRecentView.NoOfLocation = strongSelf.sortAdressArray.count
        }
    }
    
    deinit {
        if let observer1 = justDeleteItem {
            NotificationCenter.default.removeObserver(observer1)
        }
    }
    
//MARK: - Actions
    
    private func emptyArrays() {
        sortAdressArray.removeAll()
        sortLocationImgArray.removeAll()
        simpleAddressArray.removeAll()
        latArray.removeAll()
        longArray.removeAll()
    }
    
    private func swipeGesture() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissImagesVC))
        swipeDown.direction = .down
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(swipeDown)
    }
    
    private func showNoImage() {
        if bigPhotoArray.count == 0 {
            noImageLabel.isHidden = false
            topRecentView.isHidden = true
            recentLabel.isHidden = true
            collectionView.isHidden = true
            locationLabel.isHidden = true
        } else {
            noImageLabel.isHidden = true
            topRecentView.isHidden = false
            recentLabel.isHidden = false
            collectionView.isHidden = false
            locationLabel.isHidden = false
            
            fetchLocations()
            topRecentView.photoArray = self.bigPhotoArray
            topRecentView.NoOfLocation = self.sortAdressArray.count
        }
    }
    
    @objc func dismissImagesVC() {
        dismiss(animated: true, completion: nil)
    }
    
    private func showNavBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .done, target: self, action: #selector(dismissImagesVC))
    }
    
    private func hideNavBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .done, target: self, action: #selector(dismissImagesVC))
    }
    
    
    private func fetchPhotoInfo() {
        showLoadingView(true, message: "Loading...")
        recentLabel.isHidden = true
        topRecentView.isHidden = true
        locationLabel.isHidden = true
        print("DEBUG-PhotoVC: fetching images big array...")
        
        FetchingStuff.fetchPhotos(email: userMail) { pictureArray in
            self.bigPhotoArray = pictureArray
            self.showNoImage()
            self.showLoadingView(false, message: "Loading...")
        }
    }

    private func fetchLocations() {
        guard bigPhotoArray.count != 0 else { return }
        for idx in 0...bigPhotoArray.count-1 {
            let place = "\(bigPhotoArray[idx].namePlace), \(bigPhotoArray[idx].city), \(bigPhotoArray[idx].state)"
            simpleAddressArray.append(place)
        }
        
        let duplicates = Array(Set(simpleAddressArray.filter({ (i: String) in simpleAddressArray.filter({ $0 == i }).count > 1})))
        let singles = Array(Set(simpleAddressArray.filter({ (i: String) in simpleAddressArray.filter({ $0 == i }).count == 1})))
        
        //append duplications
        if duplicates.count == 0 {
            print("DEBUG-ImagesVC: no duplicates")
        } else {
            for idx in 0...duplicates.count-1 {
                sortAdressArray.append(duplicates[idx])
            }
        }
        
        //append singles
        if singles.count == 0 {
            print("DEBUG-ImagesVC: no singles")
        } else {
            for idx in 0...singles.count-1 {
                sortAdressArray.append(singles[idx])
            }
        }
        
        print("DEBUG: sort locations are \(sortAdressArray.count)")
        sortLocationsArray()
    }
    
    private func sortLocationsArray() {
        for idx in 0...sortAdressArray.count-1 {
            for ix in 0...bigPhotoArray.count-1 {
                let place = "\(bigPhotoArray[ix].namePlace), \(bigPhotoArray[ix].city), \(bigPhotoArray[ix].state)"
                if place == sortAdressArray[idx] {
                    sameLocationImgArray.append(bigPhotoArray[ix])
                }
            }
            
            sortLocationImgArray.append(sameLocationImgArray)
            latArray.append(sameLocationImgArray[0].latitude)
            longArray.append(sameLocationImgArray[0].longitude)
            sameLocationImgArray.removeAll()
        }
        
        collectionView.reloadData() //recall all the collectionView extension
    }
    
   
    
//MARK: - Deletion
    
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
    
}

//MARK: - collectionView datasource

extension ImagesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortAdressArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //configure and pass data to cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionCellID, for: indexPath) as! ImageCellCustomize
        cell.address = sortAdressArray[indexPath.row]
        cell.photoArray = sortLocationImgArray[indexPath.row]
        cell.delegate = self //to make protocols work
        cell.latitude = latArray[indexPath.row]
        cell.longitude = longArray[indexPath.row]
//        cell.itemCell = indexPath.row
        
        return cell
    }
    
}

//MARK: - Protocol ImageCellCustomize
//remember to write ".delegate = self" in ViewDidLoad
extension ImagesViewController: ImageCellCustomizeDelegate {
    func presentImagesArray(array: [Picture]) {
        let vc = PhotoArrayViewController(imgArray: array, indexValue: 0)
        vc.userEmail = userMail
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true)
    }
    
}

//MARK: - DelegateFlowlayout

extension ImagesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    //spacing for row (horizontally) between items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    //spacing for collumn (vertically) between items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    //set size for each item
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width-32, height: 80)
    }
    
}

//MARK: - SearchBar Delegate
//this extension declares what happen when user clicks on the searchBar or the "cancel" button
//remember to write "searchBarController.searchBar.delegate = self"
extension ImagesViewController: UISearchBarDelegate {
    
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
extension ImagesViewController: UISearchResultsUpdating {
    
    //this func gets called whenever we type something in the search textBox
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchBarController.searchBar.text?.lowercased() else { return }
        print("DEBUG-PhotoVC: searchText is \(searchText)")
        //Set the filteredPhotos
        self.filteredPhotos = bigPhotoArray.filter({
            $0.date.lowercased().contains(searchText) || $0.country.lowercased().contains(searchText) || $0.county.lowercased().contains(searchText) || $0.city.lowercased().contains(searchText) || $0.state.lowercased().contains(searchText) || $0.streetName.lowercased().contains(searchText) || $0.streetNo.lowercased().contains(searchText) ||
                $0.namePlace.lowercased().contains(searchText)
        }) //keep in mind, this shit is CASE SENSITIVE, so we convert both the searchText and "date, country,..." to lowercased
        
        print("DEBUG-PhotoVC: we have \(filteredPhotos.count) filtered photos")
        self.tableView.reloadData()
    } //end of func
    
}

//MARK: - tableView Datasource

extension ImagesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchMode { //whenever user type something in
            return filteredPhotos.count > 10 ? 10 : filteredPhotos.count
        } else {
            return bigPhotoArray.count > 10 ? 10 : bigPhotoArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: searchCellID, for: indexPath) as! SearchPhotoCell
        cell.photoInfo = isSearchMode ? filteredPhotos[indexPath.row] : bigPhotoArray[indexPath.row]
        
        return cell
    }
    
    
}

//MARK: - tableView Delegate
extension ImagesViewController: UITableViewDelegate {
    
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

//MARK: - Protocol RecentViewDelegate
//remember to write ".delegate = self" in ViewDidLoad
extension ImagesViewController: RecentViewDelegate {
    func showAllPhotos() {
        print("DEBUG-ImagesVC: showing array of all photos..")
        let vc = PhotoArrayViewController(imgArray: bigPhotoArray, indexValue: 0)
        vc.userEmail = userMail
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
}



