//
//  uploadInfo.swift
//  GoChat
//
//  Created by Long Nguyen on 8/8/21.
//

import UIKit
import Firebase
import CoreLocation

struct UploadInfo {
    
    //the completion block will return a string, which is the url for the image
    static func uploadProfileImage(image: UIImage, mail: String, completionBlock: @escaping(String) -> Void) {
        
        //let's make the compressionQuality little smaller so that it's faster when we download the file image from the internet
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            print("DEBUG: error setting imageData")
            return
        }
        
        //let filename = NSUUID().uuidString
        //let ref = Storage.storage().reference(withPath: "/profile_images/\(filename)")
        let ref = Storage.storage().reference(withPath: "/profile_images/\(mail)")
        
        //let's put the image into the database in Storage
        ref.putData(imageData, metadata: nil) { (metadata, error) in
            guard error == nil else {
                print("DEBUG: error putData - \(String(describing: error?.localizedDescription))")
                return
            }
            
            //let download the image that we just upload to storage
            ref.downloadURL { (url, error) in
                
                guard let imageUrl = url?.absoluteString else { return }
                completionBlock(imageUrl) //whenever this uploadImage func gets called (with an image already uploaded), we can use the downloaded url as imageUrl
                print("DEBUG-UploadInfo: profileImageUrl is \(imageUrl)")
            }
            
            print("DEBUG-UploadInfo: successfully upload image to storage")
        } //done putting image into storage
         
    }//done with this func
    
    
    //the completion block will return a string, which is the url for the image
    static func uploadLibraryImage(image: UIImage, mail: String, title: String, completionBlock: @escaping(String) -> Void) {
        
        //let's make the compressionQuality little smaller so that it's faster when we download the file image from the internet
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            print("DEBUG-UploadInfo: fail to set imageData")
            return
        }
        
        //let filename = NSUUID().uuidString
        //let ref = Storage.storage().reference(withPath: "/profile_images/\(filename)")
        let ref = Storage.storage().reference(withPath: "/library/\(mail)/\(title)")
        
        //let's put the image into the database in Storage
        ref.putData(imageData, metadata: nil) { (metadata, error) in
            if let e = error?.localizedDescription {
                print("DEBUG-UploadInfo: error putData - \(e)")
                
                return
            }
            
            //let download the image that we just upload to storage
            ref.downloadURL { (url, error) in
                
                guard let imageUrl = url?.absoluteString else { return }
                completionBlock(imageUrl) //whenever this uploadImage func gets called (with an image already uploaded), we can use the downloaded url as imageUrl
                print("DEBUG-UploadInfo: successfully upload image to storage with url \(imageUrl)")
            }
            
        } //done putting image into storage
         
    }//done with this func
    
    
    static func uploadLocationAndPhoto(userMail: String, takenImage: UIImage, photoInfo: Picture, dictionary: [String: Any], completionBlock: @escaping(Error?) -> Void) {

        let data = dictionary
        let timeLong = photoInfo.timestamp
        let cty = photoInfo.city
        var imgUrl = "no url"
        
        //upload to info database
        Firestore.firestore().collection("users").document(userMail).collection("library").document(timeLong).setData(data) { error in
            if let e = error?.localizedDescription {
                print("DEBUG-UploadInfo: error uploading info - \(e)")
                return
            }
            print("DEBUG-UploadInfo: done uploading info photo")
        }
        
        //now upload the img to Storage and update the Firestore
        uploadLibraryImage(image: takenImage, mail: userMail, title: "\(timeLong)-\(cty)") { imageUrl in
            
            imgUrl = imageUrl
            let data = ["imageURL": imgUrl] as [String: Any]
            
            Firestore.firestore().collection("users").document(userMail).collection("library").document(timeLong).updateData(data, completion: completionBlock)
        }

    }
    
    
    static func uploadLocationOnly(userMail: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, altitude: CLLocationDistance, city: String, state: String, county: String, country: String, zip: String, strName: String, strNo: String, completionBlock: @escaping(Error?) -> Void) {

        Time.configureTime { timeArray in //index 0 is timeKey, 1 is timeShort
            let timeLong = timeArray[0]
            let timeAbbre = timeArray[1]
            let imgUrl = "no url"
            
            let data = ["latitude": latitude,
                        "longitude": longitude,
                        "altitude": altitude,
                        "city": city,
                        "state": state,
                        "county": county,
                        "country": country,
                        "zipcode": zip,
                        "streetName": strName,
                        "streetNumber": strNo,
                        "timestamp": timeLong,
                        "date": timeAbbre,
                        "imageURL": imgUrl] as [String : Any]

            //upload to database
            Firestore.firestore().collection("users").document(userMail).collection("library").document(timeLong).setData(data, completion: completionBlock)
        }

    }
    
    
    
    
}
