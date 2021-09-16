//
//  PictureAnnotation.swift
//  GoChat
//
//  Created by Long Nguyen on 8/15/21.
//

import UIKit
import MapKit

class PictureAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var timing: String
    
    init(time: String, coorPicture: CLLocationCoordinate2D) {
        self.coordinate = coorPicture
        self.timing = time
    }
    
}

//class ManyPictAnnotation: NSObject, MKAnnotation {
//
//    var coordinate: CLLocationCoordinate2D
//    var timing: String
//
//    init(time: String, coorPicture: CLLocationCoordinate2D) {
//        self.coordinate = coorPicture
//        self.timing = time
//    }
//
//}
