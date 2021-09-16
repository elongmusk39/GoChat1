//
//  ImageCell.swift
//  GoChat1
//
//  Created by Long Nguyen on 8/27/21.
//

import UIKit
import MapKit

protocol ImageCellCustomizeDelegate: AnyObject {
    func presentImagesArray(array: [Picture])
}

class ImageCellCustomize: UICollectionViewCell {
    
    weak var delegate: ImageCellCustomizeDelegate?
    
    var photoArray = [Picture]() {
        didSet {
            noOfPhotosLabel.text = "\(photoArray.count) photos"
        }
    }
    var address: String! {
        didSet {
            addressLabel.text = address
        }
    }
    
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees! {
        didSet {
            configureMapView()
        }
    }
    
//MARK: - Components
    
    private let mapView = MKMapView()
    private let mapDimension: CGFloat = 64
    
    private let photoView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.image = #imageLiteral(resourceName: "greenGoChat")
        
        return iv
    }()
    
    private let addressLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.boldSystemFont(ofSize: 14)
        lb.text = "1234 whiteHouse st"
        lb.numberOfLines = 2
        lb.textColor = .green.withAlphaComponent(0.87)
        
        return lb
    }()
    
    private let noOfPhotosLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.boldSystemFont(ofSize: 12)
        lb.text = "12 photos"
        lb.numberOfLines = 1
        lb.textColor = .lightGray
        
        return lb
    }()
    
    private lazy var arrowIndicator: UIImageView = {
        let iv = UIImageView() //we dont need contentMode here
        iv.image = UIImage(systemName: "chevron.right.circle")
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .green
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showPhotoArray))
        iv.addGestureRecognizer(tap)
        
        return iv
    }()
    
//MARK: - View Scene
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white.withAlphaComponent(0.12)
        layer.cornerRadius = 20
        let tap = UITapGestureRecognizer(target: self, action: #selector(showPhotoArray))
        addGestureRecognizer(tap)
        
        //mapView
        mapView.isUserInteractionEnabled = false
        mapView.overrideUserInterfaceStyle = .dark
        
        addSubview(mapView)
        mapView.layer.cornerRadius = mapDimension / 2
        mapView.layer.borderWidth = 0.7
        mapView.layer.borderColor = UIColor.black.cgColor
        mapView.anchor(left: leftAnchor, paddingLeft: 12, width: mapDimension, height: mapDimension)
        mapView.centerY(inView: self)
        
        //arrow
        addSubview(arrowIndicator)
        arrowIndicator.anchor(right: rightAnchor, paddingRight: 12, width: 30, height: 30)
        arrowIndicator.centerY(inView: self)
        arrowIndicator.layer.cornerRadius = 20/2
        
        //address and number of photos
        let stack = UIStackView(arrangedSubviews: [addressLabel, noOfPhotosLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        addSubview(stack)
        stack.anchor(left: mapView.rightAnchor, right: arrowIndicator.leftAnchor, paddingLeft: 8, paddingRight: 8)
        stack.centerY(inView: self)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - Actions
    
    @objc func showPhotoArray() {
        delegate?.presentImagesArray(array: photoArray)
    }
    
    func configureMapView() {
        let coor = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)

        //let's setup the region
        let region = MKCoordinateRegion(center: coor, latitudinalMeters: 1200, longitudinalMeters: 1200) //make 100m distance around the center
        mapView.setRegion(region, animated: false)

        //let's add annotation to configure the center
        let anno = MKPointAnnotation()
        anno.coordinate = coor
        mapView.addAnnotation(anno)
//        mapView.selectAnnotation(anno, animated: true) //make anno big
    }
    
    
}

