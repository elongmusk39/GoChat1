//
//  Deletion.swift
//  GoChat
//
//  Created by Long Nguyen on 8/17/21.
//

import UIKit
import Firebase

struct Deletion {
    
    static func deleteItem(currentMail: String, nameItem: String, completionBlock: @escaping(Error?) -> Void) {
        
//        let ref = Storage.storage().reference(withPath: "/library/\(currentMail)/\(title)")
        
        Firestore.firestore().collection("users").document(currentMail).collection("library").document(nameItem).delete(completion: completionBlock)
        
    }
    
}
