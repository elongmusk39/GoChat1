//
//  DecoyImageCell.swift
//  GoChat
//
//  Created by Long Nguyen on 8/24/21.
//

import UIKit
import SDWebImage

//protocol declared in ImagesVC
protocol DecoyImageCellDelegate: AnyObject {
    func appendFetchImage(img: UIImageView)
}

class DecoyImageCell: UICollectionViewCell {
    
    weak var delegate: DecoyImageCellDelegate?
    
    var photoInfo: Picture? {
        didSet {
//            pictView.sd_setImage(with: photoURL)
            configureUI()
        }
    }
    
//    private var photoURL: URL? {
//        let urlString = photoInfo?.imageUrl ?? "no url"
//        return URL(string: urlString)
//    }
    
//MARK: - Components
        
    //make it "lazy var" so that it loads the tap gesture
    lazy var pictView: UIImageView = {
        let iv = UIImageView() //we dont need contentMode here
        iv.image = #imageLiteral(resourceName: "greenGoChat")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(appendProtocol))
        iv.addGestureRecognizer(tap)
        
        return iv
    }()
    
//MARK: - View Scenes
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//MARK: - Actions
    
    private func configureUI() {
        print("DEBUG-DecoyImageCell: setting UI")
        addSubview(pictView)
        pictView.frame = self.bounds
    }
    
    @objc func appendProtocol() {
       
    }
    
    
    
}

