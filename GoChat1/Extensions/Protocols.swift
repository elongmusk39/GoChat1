//
//  Protocols.swift
//  GoChat
//
//  Created by Long Nguyen on 8/4/21.
//

import UIKit

extension Notification.Name {
    
    static let didLogOut = Notification.Name("didLogOut")
    static let didLogIn = Notification.Name("didLogIn")
    static let loadingView = Notification.Name("loadingView")
    static let didChangeUserInfo = Notification.Name("didChangeUserInfo")
    
    static let enableScroll = Notification.Name("enableScroll")
    static let disableScroll = Notification.Name("disableScroll")
    
    static let deleteItem = Notification.Name("deleteItem")
    
    static let chosenLongPress = Notification.Name("chosenLongPress")
    
    static let refreshMap = Notification.Name("refreshMap")
        
    static let presentPhotoVC = Notification.Name("presentPhotoVC")
    static let deleteFromPhotoVC = Notification.Name("deleteFromPhotoVC")
}
