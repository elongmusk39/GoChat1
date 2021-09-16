//
//  User.swift
//  GoChat
//
//  Created by Long Nguyen on 8/8/21.
//

import UIKit
import Firebase

struct User {
    var email: String
    var password: String
    var username: String
    var uid: String
    var profileImageUrl: String
    
    init(dictionary: [String : Any]) {
        self.email = dictionary["email"] as? String ?? "no email"
        self.password = dictionary["password"] as? String ?? "no pass"
        self.username = dictionary["username"] as? String ?? "no username"
        self.uid = dictionary["userID"] as? String ?? "no uid"
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? "no imageURL"
        //all the shit "" must match the "" in "data" in AuthService
    }
    
}
