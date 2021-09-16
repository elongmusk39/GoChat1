//
//  ViewModelLogIn.swift
//  GoChat
//
//  Created by Long Nguyen on 8/3/21.
//

import Foundation

struct ViewModelLogin {
    
    var email: String?
    var password: String?
    
    var formIsValid: Bool {
        //if the line below is true, then we return formIsValid == true
        return email?.isEmpty == false && password?.isEmpty == false
    }
}
