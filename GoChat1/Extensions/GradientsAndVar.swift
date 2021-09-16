//
//  Gradients.swift
//  GoChat
//
//  Created by Long Nguyen on 8/2/21.
//


var sectionScrollAfterDeletion: Int = 1


import UIKit

extension UIViewController {
    
    func configureGradientLayer (from: NSNumber, to: NSNumber) {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemGreen.cgColor, UIColor.white.cgColor]
        gradient.locations = [from, to] //the gradient works vertically, the marks indicate where the gradient (2 or more colors equally divided) starts and stops. the entire screen is 0 -> 1
        
        //those lines insert the gradient into the view
        view.layer.addSublayer(gradient)
        gradient.frame = view.frame
    }
    
    
}
