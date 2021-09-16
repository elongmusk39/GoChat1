//
//  Picture.swift
//  GoChat
//
//  Created by Long Nguyen on 8/8/21.
//

import UIKit
import MapKit

struct Picture {
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var altitude: CLLocationDegrees
    var country: String
    var city: String
    var county: String
    var state: String
    var streetName: String
    var streetNo: String
    var zipcode: String
    var namePlace: String
    var timestamp: String
    var date: String
    var imageUrl: String
//    var imageRealm: UIImage?
    
    //dictionary only used when fetching from Cloud Database
    init(dictionary: [String : Any]) {
        self.latitude = dictionary["latitude"] as? CLLocationDegrees ?? 0
        self.longitude = dictionary["longitude"] as? CLLocationDegrees ?? 0
        self.altitude = dictionary["altitude"] as? CLLocationDegrees ?? 0
        self.country = dictionary["country"] as? String ?? "no country"
        self.county = dictionary["county"] as? String ?? "no county"
        self.city = dictionary["city"] as? String ?? "no city"
        self.state = dictionary["state"] as? String ?? "no state"
        self.streetName = dictionary["streetName"] as? String ?? "no strName"
        self.streetNo = dictionary["streetNumber"] as? String ?? "no strNo"
        self.zipcode = dictionary["zipcode"] as? String ?? "no zip"
        self.namePlace = dictionary["placeName"] as? String ?? "-"
        self.timestamp = dictionary["timestamp"] as? String ?? "no time"
        self.date = dictionary["date"] as? String ?? "no date"
        self.imageUrl = dictionary["imageURL"] as? String ?? "no imageURL"
        
        //all the shit "" must match the "" in "data" in UploadInfo
    }
    
}
