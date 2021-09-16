//
//  FetchingStuff.swift
//  GoChat
//
//  Created by Long Nguyen on 8/8/21.
//

import UIKit
import Firebase

struct FetchingStuff {
    
    static func fetchUserInfo(currentEmail: String, completion: @escaping(User) -> Void) {
        print("DEBUG-FetchingStuff: fetching user info..")
        
        Firestore.firestore().collection("users").document(currentEmail).getDocument { (snapshot, error) in
            
            if let e = error?.localizedDescription {
                print("DEBUG-FetchingStuff: cant fetch userInfo..\(e)")
                return
            }
            guard let dictionaryUser = snapshot?.data() else {
                print("DEBUG-FetchingStuff: error setting user data..")
                return
            }
            let userInfoFetched = User(dictionary: dictionaryUser)
            completion(userInfoFetched)
        }
    }
    
    
    static func fetchPhotos(email: String, completion: @escaping([Picture]) -> Void) {
        
        let query = Firestore.firestore().collection("users").document(email).collection("library").order(by: "timestamp", descending: true) //fetch data base on chronological order, either true or false
        
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            print("DEBUG-FetchingStuff: we have \(documents.count) photos")
            
            //this "map" function get run as many times as "documents.count" to fill in the array. either use this or for-loop func
            let photoArray = documents.map({
                Picture(dictionary: $0.data()) //get all data in a document
            })
            print("DEBUG-FetchingStuff: we now have big array of all photos")//show photoArray
            completion(photoArray)
        }
        
    }
    
    static func fetchPhotoInfo(email: String, timeKey: String, completion: @escaping(Picture) -> Void) {
        
        let query = Firestore.firestore().collection("users").document(email).collection("library").document(timeKey)
            
        query.getDocument { snapshot, error in
            
            if let e = error?.localizedDescription {
                print("DEBUG-FetchingStuff: cant fetch picture Info..\(e)")
                return
            }
            
            guard let dictionaryPhoto = snapshot?.data() else {
                print("DEBUG-FetchingStuff: error setting photo info..")
                return
            }
            
            let pictureInfoFetched = Picture(dictionary: dictionaryPhoto)
            completion(pictureInfoFetched)
        }
        
    }
    
    
//    static func fetchPhotosWithPaginition(paginated: Bool, email: String, completion: @escaping([Picture]) -> Void) {
//        
//        let query = Firestore.firestore().collection("users").document(email).collection("library").order(by: "timestamp", descending: true) //fetch data base on chronological order, either true or false
//        
//        query.getDocuments { (snapshot, error) in
//            guard let documents = snapshot?.documents else { return }
//            print("DEBUG-FetchingStuff: we have \(documents.count) photos")
//            
//            //this "map" function get run as many times as "documents.count" to fill in the array. either use this or for-loop func
//            let bigPhotoArray = documents.map({
//                Picture(dictionary: $0.data()) //get all data in a document
//            })
//            
//            completion(bigPhotoArray)
//        }
//        
//    }
    
    
    
    
}
