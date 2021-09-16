//
//  SearchPhotoCell.swift
//  GoChat
//
//  Created by Long Nguyen on 8/19/21.
//

import UIKit
import SDWebImage

class SearchPhotoCell: UITableViewCell {
    
    var photoInfo: Picture! {
        didSet {
            setPhotoData()
        }
    }
    
    private var photoURL: URL? {
        let urlString = photoInfo?.imageUrl ?? "no url"
        return URL(string: urlString)
    }
    
//MARK: - Components
    
    private let photoView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.image = #imageLiteral(resourceName: "greenGoChat")
        iv.layer.cornerRadius = 8
        
        return iv
    }()
    
    private let addressLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.boldSystemFont(ofSize: 16)
        lb.text = "1234 whiteHouse st"
        lb.numberOfLines = 1
        lb.textColor = .green
        
        return lb
    }()
    
    private let dateLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16)
        lb.text = "June 17, 2020"
        lb.numberOfLines = 1
        lb.textColor = .lightGray
        
        return lb
    }()
    
//MARK: - View Scene
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .black
        
        addSubview(photoView)
        photoView.anchor(left: leftAnchor, paddingLeft: 8, width: 56, height: 72) //rowHeight is 88 (adjust in PhotoVC)
        photoView.centerY(inView: self)
        
        let stackView = UIStackView(arrangedSubviews: [addressLabel, dateLabel])
        stackView.axis = .vertical
        stackView.spacing = 14
        stackView.alignment = .leading //anchor to the left
        addSubview(stackView)
        stackView.anchor(left: photoView.rightAnchor, right: rightAnchor, paddingLeft: 8, paddingRight: 8)
        stackView.centerY(inView: photoView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - Actions
    
    private func setPhotoData() {
        photoView.sd_setImage(with: photoURL)
//        let address = "\(photoInfo.streetNo) \(photoInfo.streetName), \(photoInfo.city), \(photoInfo.county), \(photoInfo.state), \(photoInfo.country)"
        let addressShort = "\(photoInfo.streetName), \(photoInfo.city), \(photoInfo.namePlace), \(photoInfo.state)"
        
        addressLabel.text = addressShort
        dateLabel.text = photoInfo.date
    }
    
    
}
