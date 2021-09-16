//
//  PhotoItem.swift
//  GoChat
//
//  Created by Long Nguyen on 8/16/21.
//

import UIKit
import SDWebImage

//protocol gets called in PhotoArrayVC
protocol PhotoItemDelegate: AnyObject {
    func showMapView(_ cell: PhotoItem, time: String)
    func dismissVC()
    func shareImage(imgShare: UIImage)
    func deleteImage(index: Int)
}

class PhotoItem: UICollectionViewCell {
    
    weak var delegate: PhotoItemDelegate?
    var numberArray: Int = 0
    var photoIndex: Int = 0 {
        didSet {
            orderLabel.text = "\(numberArray-photoIndex) / \(numberArray)"
        }
    }
    
    //this var got filled in the Datasource of PhotoArrayVC
    var photoInfo: Picture! {
        didSet {
            print("DEBUG-PhotoItem: setting photo..")
            photoView.sd_setImage(with: photoURL)
        }
    }
    
    private var photoURL: URL? {
        let urlString = photoInfo?.imageUrl ?? "no url"
        print("DEBUG-PhotoItem: return a img urlString")
        return URL(string: urlString)
    }
    
//MARK: - Components
    
    private let scrollView = UIScrollView()
    
    private let photoView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .black
        iv.isUserInteractionEnabled = true
        
        return iv
    }()
    
    private let bottomView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        
        return vw
    }()
    
    //gotta make this a "lazy var" in order to addTarget when creating a button in a cell or small view like this. In case of creating a btn in a VC, no need "lazy var".
    private lazy var dismissButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "xmark.circle"), for: .normal)
        btn.tintColor = .green
        btn.setDimensions(height: 28, width: 28)
        
        btn.addTarget(self, action: #selector(dismissArray), for: .touchUpInside)
        
        return btn
    }()
    
    private let orderLabel: UILabel = {
        let lb = UILabel()
        lb.text = "1 / 12"
        lb.textColor = .green
        lb.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        return lb
    }()
    
    //gotta make this a "lazy var" in order to addTarget
    private lazy var showLocationButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Location", for: .normal)
        btn.backgroundColor = .black
        btn.tintColor = .green
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.green.cgColor
        btn.layer.cornerRadius = 12
        btn.setDimensions(height: 40, width: 120)
        
        btn.addTarget(self, action: #selector(showLocation), for: .touchUpInside)
        
        return btn
    }()
    
    //gotta make this a "lazy var" in order to addTarget
    private lazy var shareButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        btn.tintColor = .green
        btn.setDimensions(height: 32, width: 32)
        btn.addTarget(self, action: #selector(shareOn), for: .touchUpInside)
        
        return btn
    }()
    
    //gotta make this a "lazy var" in order to addTarget
    private lazy var sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "arrowshape.turn.up.right"), for: .normal)
        btn.tintColor = .green
        btn.setDimensions(height: 32, width: 32)
        btn.addTarget(self, action: #selector(dismissArray), for: .touchUpInside)
        
        return btn
    }()
    
    private lazy var saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "tray.and.arrow.down"), for: .normal)
        btn.tintColor = .green
        btn.setDimensions(height: 32, width: 32)
        btn.addTarget(self, action: #selector(saveToLibrary), for: .touchUpInside)
        
        return btn
    }()
    
    private let saveLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Saved!"
        lb.textColor = .green
        lb.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lb.isHidden = true
        lb.alpha = 0
        return lb
    }()
    
    private lazy var deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "trash"), for: .normal)
        btn.tintColor = .green
        btn.setDimensions(height: 32, width: 32)
        btn.addTarget(self, action: #selector(deleteImage), for: .touchUpInside)
        
        return btn
    }()
    
    
//MARK: - View Scenes
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        backgroundColor = .lightGray
        configureUI()
        swipeGesture()
        scrollViewZoom()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        
        addSubview(scrollView)
        scrollView.frame = self.bounds
        
        scrollView.addSubview(photoView)
        photoView.frame = scrollView.bounds
        
        addSubview(dismissButton)
        dismissButton.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, paddingTop: 4, paddingLeft: 8)
        
        addSubview(orderLabel)
        orderLabel.centerX(inView: self)
        orderLabel.centerY(inView: dismissButton)
        
        addSubview(bottomView)
        bottomView.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, height: 36)
        
        let stack = UIStackView(arrangedSubviews: [shareButton, deleteButton, showLocationButton, saveButton, sendButton])
        stack.distribution = .equalSpacing
        stack.axis = .horizontal
        bottomView.addSubview(stack)
        stack.anchor(left: bottomView.leftAnchor, right: bottomView.rightAnchor, paddingLeft: 12, paddingRight: 12)
        stack.centerY(inView: bottomView)
        
        addSubview(saveLabel)
        saveLabel.anchor(bottom: bottomView.topAnchor, paddingBottom: 12)
        saveLabel.centerX(inView: saveButton)
        
    }
    
//MARK: - Actions
    
    private func swipeGesture() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(showLocation))
        swipeUp.direction = .up
        addGestureRecognizer(swipeUp)
    }
    
    @objc func showLocation() {
        guard let timeTaken = photoInfo?.timestamp else { return }
        delegate?.showMapView(self, time: timeTaken) //delegate back to PhotoArrayVC
    }
    
    @objc func dismissArray() {
        delegate?.dismissVC() //delegate back to PhotoArrayVC
    }
    
    @objc func sendTo() {
        
    }
    
    @objc func shareOn() {
        guard let img = photoView.image else { return }
        delegate?.shareImage(imgShare: img)
    }
    
    @objc func saveToLibrary() {
        guard let imageToSave = photoView.image else {
            print("DEBUG-PhotoItem: unable to save image")
            return
        }
        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil) //this will require access to photo library, so gotta check auth status and add "privacy" in the info.plist
        
        UIView.animate(withDuration: 0.75) {
            self.saveLabel.isHidden = false
            self.saveLabel.alpha = 1
        }
        
    }
    
    @objc func deleteImage() {
        delegate?.deleteImage(index: photoIndex)
    }
    
    private func scrollViewZoom() { //this func needs extension UIScrollViewDelegate
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.delegate = self
    }
    
    
    
    
}

//MARK: - scrollView to zoom
//remember to write "scrollView.delegate = self" in viewDidLoad
extension PhotoItem: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            if let image = photoView.image {
                let ratioW = photoView.frame.width / image.size.width
                let ratioH = photoView.frame.height / image.size.height
                
                let ratio = ratioW < ratioH ? ratioW : ratioH
                let newWidth = image.size.width * ratio
                let newHeight = image.size.height * ratio
                
                let conditionLeft = newWidth*scrollView.zoomScale > photoView.frame.width
                let leftAn = 0.5 * (conditionLeft ? (newWidth - photoView.frame.width) : (scrollView.frame.width - scrollView.contentSize.width))
                
                let conditionTop = newHeight*scrollView.zoomScale > photoView.frame.height
                let topAn = 0.5 * (conditionTop ? (newHeight - photoView.frame.height) : (scrollView.frame.height - scrollView.contentSize.height))
                
                scrollView.contentInset = UIEdgeInsets(top: topAn, left: leftAn, bottom: topAn, right: leftAn)
            }
        } else {
            scrollView.contentInset = .zero
        }
        
    }
    
}
