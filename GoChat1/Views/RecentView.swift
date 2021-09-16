//
//  RecentView.swift
//  GoChat1
//
//  Created by Long Nguyen on 9/4/21.
//

import UIKit
import SDWebImage

protocol RecentViewDelegate: AnyObject {
    func showAllPhotos()
}

class RecentView: UIView {
    
    weak var delegate: RecentViewDelegate?
    
    var NoOfLocation: Int? {
        didSet {
            guard let locations = NoOfLocation else { return }
            locationNoLabel.text = "\(locations) locations"
        }
    }
    
    var photoArray = [Picture]() {
        didSet {
            photoNoLabel.text = "Total: \(photoArray.count) photos"
            pictView.sd_setImage(with: photoURL)
        }
    }
    
    private var photoURL: URL? {
        let urlString = photoArray[0].imageUrl 
        print("DEBUG-RecentView: return a img urlString")
        return URL(string: urlString)
    }
    
//MARK: - Components
    
    //make it "lazy var" so that it loads the tap gesture
    private lazy var pictView: UIImageView = {
        let iv = UIImageView() //we dont need contentMode here
        iv.image = #imageLiteral(resourceName: "greenGoChat")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(showPhotoArray))
//        iv.addGestureRecognizer(tap)
        
        return iv
    }()
    
    private let photoNoLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lb.text = "Total: 100 photos"
        lb.textAlignment = .center
        lb.textColor = .lightGray
        
        return lb
    }()
    
    private let locationNoLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lb.text = "23 locations"
        lb.textAlignment = .center
        lb.textColor = .green.withAlphaComponent(0.87)
        
        return lb
    }()
    
    private let arrowIndicator: UIImageView = {
        let iv = UIImageView() //we dont need contentMode here
        iv.image = UIImage(systemName: "chevron.right.circle")
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .green
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        
        return iv
    }()
    
//MARK: - View Scenes
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //basic setup
        setHeight(height: 100)
        backgroundColor = .white.withAlphaComponent(0.12)
        layer.cornerRadius = 20
        
        //add tap gresture
        let tap = UITapGestureRecognizer(target: self, action: #selector(showPhotoArray))
        self.addGestureRecognizer(tap)
        
        //set up components
        addSubview(pictView)
        pictView.anchor(left: leftAnchor, paddingLeft: 12, width: 54, height: 72)
        pictView.centerY(inView: self)
        pictView.layer.cornerRadius = 10
        
        addSubview(arrowIndicator)
        arrowIndicator.anchor(right: rightAnchor, paddingRight: 12, width: 30, height: 30)
        arrowIndicator.centerY(inView: self)
        arrowIndicator.layer.cornerRadius = 20/2
        
        let stack = UIStackView(arrangedSubviews: [locationNoLabel, photoNoLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 16
        addSubview(stack)
        stack.anchor(left: pictView.rightAnchor, right: arrowIndicator.leftAnchor, paddingLeft: 12, paddingRight: 12)
        stack.centerY(inView: self)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - Actions
    
    @objc func showPhotoArray() {
        delegate?.showAllPhotos()
    }
    
    
}
