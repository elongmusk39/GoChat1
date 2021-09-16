//
//  Auth.swift
//  GoChat
//
//  Created by Long Nguyen on 8/3/21.
//

import UIKit
import Firebase

struct Authentication {
    
    static func signOut(completion: @escaping(String) -> Void) {
        let userEmail = Auth.auth().currentUser?.email ?? "nil"
        
        do {
            try Auth.auth().signOut()
            print("DEBUG-Authentication: done signing out \(userEmail)")
            completion(userEmail) //make this just for the completion block to be executed
        } catch  {
            print("DEBUG: error signing out \(userEmail)")
        }
    }
    
    
    
    
}
