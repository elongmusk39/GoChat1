//
//  PhotoCell.swift
//  GoChat
//
//  Created by Long Nguyen on 8/12/21.
//

import UIKit
import SDWebImage

//protocol gets called in PhotoVC. We need "_ cell: PhotoCell" to make sure the protocol works
protocol PhotoCellDelegate: AnyObject {
    func showMapPhotoVC(_ cell: PhotoCell, time: String)
    func showBigPhotoArray(_ cell: PhotoCell, index: Int)
    func chosenArray(_ cell: PhotoCell, append: Bool, index: Int)
}

class PhotoCell: UICollectionViewCell {
    
    weak var delegate: PhotoCellDelegate?
    
    var itemCell: Int? //the original indexPath.row in PhotoVC
    var isPicked = false
    
    var isEditing = false { //get frequently changed in PhotoVC
        didSet {
            configureEdit()
        }
    }
    
    //this var got filled in the Datasource of PhotoVC
    var photoInfo: Picture! {
        didSet {
            photoView.sd_setImage(with: photoURL)
//            let downsampledLadyImage = downsample(imgURL: photoURL, pointSize: photoView.bounds.size)
//            print("DEBUG: img is \(downsampledLadyImage)")
//            photoView.image = downsampledLadyImage
        }
    }
    
    private var photoURL: URL! {
        let urlString = photoInfo?.imageUrl ?? "no url"
        return URL(string: urlString)
    }
    
//MARK: - Components
    
    private let tickView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .green
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "circle")
        
        return iv
    }()
        
    //make it "lazy var" so that it loads the tap gesture
    lazy var photoView: UIImageView = {
        let iv = UIImageView() //we dont need contentMode here
        iv.image = #imageLiteral(resourceName: "greenGoChat")
        iv.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showBigPhotoOrChosen))
        iv.addGestureRecognizer(tap)
        
        return iv
    }()
    
    //gotta make this a "lazy var" in order to addTarget. If you make it "let", the cell initially has not added the button so it has no place to addTarget. The "lazy var" will load the button once the func init in lifecycle gets called, which we now have a button to addTarget
    private lazy var locationButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "mappin.and.ellipse"), for: .normal)
        btn.tintColor = .green
        btn.backgroundColor = .clear
        btn.contentMode = .scaleAspectFit
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(showLocationVC), for: .touchUpInside)

        return btn
    }()
    
    
//MARK: - View Scenes
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //main interface
        addSubview(photoView)
        photoView.frame = self.bounds
        
        addSubview(locationButton)
        locationButton.anchor(bottom: bottomAnchor, right: rightAnchor, paddingBottom: 4, paddingRight: 4, width: 30, height: 30)
        
        configureEdit()
        
        //in editing process
        addSubview(tickView)
        tickView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, paddingTop: 4, paddingLeft: 4, width: 32, height: 32)
        tickView.layer.cornerRadius = 32/2
        tickView.isHidden = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configureEdit() {
        if isEditing {
            tickView.isHidden = false
            locationButton.isHidden = true
        } else {
            tickView.image = UIImage(systemName: "circle")
            tickView.isHidden = true
            locationButton.isHidden = false
            photoView.alpha = 1
        }
        
    }
    
    
//MARK: - Actions
    
    func configureImage(url: String) {
        print("DEBUG-PhotoCell: configuring image...")
        photoView.load(urlString: url)
    }
    
    
    private func downsample(imgURL: URL, pointSize: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        
        // Create an CGImageSource that represent an image
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(imgURL as CFURL, imageSourceOptions) else {
            return nil
        }
        
        // Calculate the desired dimension
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        
        // Perform downsampling
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }
        
        // Return the downsampled image as UIImage
        return UIImage(cgImage: downsampledImage)
    }
    
    
    @objc func showLocationVC() {
        guard let timeTaken = photoInfo?.timestamp else { return }
        delegate?.showMapPhotoVC(self, time: timeTaken)
    }
    
    private func pickingState(imgName: String, alpha: CGFloat, picked: Bool) {
        let imageTick = UIImage(systemName: imgName)
        tickView.image = imageTick
        photoView.alpha = alpha
        isPicked = picked
    }
    
    @objc func showBigPhotoOrChosen() {
        guard let indexNo = itemCell else { return }
        
        if isEditing {
            if isPicked == true {
                pickingState(imgName: "circle", alpha: 1, picked: false)
                delegate?.chosenArray(self, append: false, index: indexNo)
            } else {
                pickingState(imgName: "circle.fill", alpha: 0.47, picked: true)
                delegate?.chosenArray(self, append: true, index: indexNo)
            }
        } else {
            delegate?.showBigPhotoArray(self, index: indexNo)
        }
        
    }
    
    
}
