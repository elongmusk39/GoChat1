//
//  PhotoArrayViewController.swift
//  GoChat
//
//  Created by Long Nguyen on 8/16/21.
//

import UIKit
import Firebase

private let cellArrayID = "cellArrayID"


class PhotoArrayViewController: UIViewController {
    
    private var photoArray = [Picture]()
    var userEmail = ""
    private var indexItem: Int! //got value from ImagesVC to scroll to the right img
    private var justDelete = false
    
//MARK: - Components
    
    //"lazy var" since we gotta register the cell after loading
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .black
        cv.register(PhotoItem.self, forCellWithReuseIdentifier: cellArrayID)
        
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.isPagingEnabled = true
        
        return cv
    }()
    
//MARK: - View Scenes
    //got value from PhotoVC
    init(imgArray: [Picture], indexValue: Int) {
        self.photoArray = imgArray
        self.indexItem = indexValue
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        swipeGesture()
        scrollToImage(value: indexItem)
    }
    
    //let's set default color for status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
    private func configureUI() {
        view.addSubview(collectionView)
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor)
    }
    
//MARK: - Actions

    private func swipeGesture() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissPhotoArray))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    private func scrollToImage(value: Int) {
        print("DEBUG-PhotoArrayVC: scrolling to img \(value)..")
        collectionView.scrollToItem(at: IndexPath(item: value, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    
    @objc func dismissPhotoArray() {
        dismiss(animated: true, completion: nil)
        if justDelete {
            NotificationCenter.default.post(name: .deleteItem, object: nil)
        }
    }
    
//MARK: - Deletion
    
    private func deleteAlert(rowIndex: Int) {
        let alert = UIAlertController (title: "Deleted this item?", message: "This photo will be permanently deleted from the server", preferredStyle: .alert)
        let cancel  = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let delete = UIAlertAction (title: "Delete", style: .destructive) { delete in
            self.nowDelete(rowNumber: rowIndex)
        }
        
        alert.addAction(cancel)
        alert.addAction(delete)
        present(alert, animated: true, completion: nil)
    }
    
    private func nowDelete(rowNumber: Int) {
        print("DEBUG-PhotoArrayVC: deletion \(rowNumber) confirmed..")
        self.showLoadingView(true, message: "Deleting..")
        
        let timeTaken = photoArray[rowNumber].timestamp
        let nameStorage = "\(photoArray[rowNumber].timestamp)-\(photoArray[rowNumber].city)"
        
        let ref = Storage.storage().reference(withPath: "/library/\(userEmail)/\(nameStorage)")
        ref.delete { error in
            if let e = error?.localizedDescription {
                self.alert(error: e, buttonNote: "Try Again")
                return
            }
            print("DEBUG-PhotoArrayVC: done delete in storage, now in firestore..")
            Firestore.firestore().collection("users").document(self.userEmail).collection("library").document(timeTaken).delete { error in
                
                self.showLoadingView(false, message: "Deleting..")
                if let e = error?.localizedDescription {
                    self.alert(error: e, buttonNote: "Try again")
                    return
                }
                print("DEBUG-PhotoArrayVC: sucessfully deleting item")
                self.justDelete = true
                self.doneDeletion(idx: rowNumber)
                
            }
        }
        
    }
    
    private func doneDeletion(idx: Int) {
        if idx == 0 && photoArray.count > 1 {
            photoArray.remove(at: idx)
            collectionView.reloadData()
            scrollToImage(value: idx) //should be idx+1 but we reload data
        } else if idx == photoArray.count-1 && photoArray.count>1 {
            photoArray.remove(at: idx)
            collectionView.reloadData()
            scrollToImage(value: idx) //should be idx-1 but we reload data
        } else if photoArray.count == 1 {
            dismissPhotoArray()
        } else if photoArray.count > 2 && idx>0 && idx<photoArray.count-1 {
            photoArray.remove(at: idx)
            collectionView.reloadData()
            scrollToImage(value: idx) //should be idx+1 or -1 but we reload data
        }
        
    }
    
    
}

//MARK: - collectionView datasource
//remember to write ".delegate = self" to enable all of extensions
extension PhotoArrayViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellArrayID, for: indexPath) as! PhotoItem
        cell.photoInfo = photoArray[indexPath.row]
        cell.numberArray = photoArray.count
        cell.photoIndex = indexPath.row //assign the index to each item
        cell.delegate = self //to make protocols work
        
        return cell
    }
    
    
}

//MARK: - DelegateFlowlayout and Delegate

extension PhotoArrayViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    //spacing for row (horizontally) between items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    //spacing for collumn (vertically) between items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    
    //set size for each item
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
}

//MARK: - Protocol from PhotoItem
//remember to write ".delegate = self" in Datasource
extension PhotoArrayViewController: PhotoItemDelegate {
    
    func dismissVC() {
        dismissPhotoArray()
    }
    
    func showMapView(_ cell: PhotoItem, time: String) {
        let vc = MapPhotoViewController(timeOfPhoto: time)
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen
        vc.currentEmail = userEmail
        present(vc, animated: true, completion: nil)
    }
    
    func shareImage(imgShare: UIImage) {
        let shareText = "Share Image"
        
        let vc = UIActivityViewController(activityItems: [shareText, imgShare], applicationActivities: nil)
        present(vc, animated: true, completion: nil)
    }
    
    func deleteImage(index: Int) {
        deleteAlert(rowIndex: index)
    }
    
    
    
}
