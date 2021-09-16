//
//  NavBarExtensions.swift
//  GoChat
//
//  Created by Long Nguyen on 7/30/21.
//

import UIKit

extension UIViewController {
    
    //let's customize the navigation bar
    func configureNavigationBar (title: String, preferLargeTitle: Bool, backgroundColor: UIColor, buttonColor: UIColor, interface: UIUserInterfaceStyle) {
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground() //just call it
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] //enables us to set our big titleColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white] //set titleColor
        appearance.backgroundColor = backgroundColor
        
        //just call it for the sake of calling it
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance //when you scroll down, the nav bar just shrinks
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        //specify what show be showing up on the nav bar
        navigationController?.navigationBar.prefersLargeTitles = preferLargeTitle
        navigationItem.title = title
        navigationController?.navigationBar.tintColor = buttonColor //enables us to set the color for the image or any nav bar button
        navigationController?.navigationBar.isTranslucent = true
        
        //this line below specifies the status bar (battery, wifi display) to white, this line of code is only valid for large title nav bar
        navigationController?.navigationBar.overrideUserInterfaceStyle = interface
        
    }
    
    
}
