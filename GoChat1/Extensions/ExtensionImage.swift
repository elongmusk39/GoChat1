//
//  ExtensionImage.swift
//  GoChat
//
//  Created by Long Nguyen on 8/26/21.
//

import UIKit

var imageCache = NSCache<AnyObject, AnyObject>()
extension UIImageView {
    func load(urlString: String) {
        
        if let photo = imageCache.object(forKey: urlString as NSString) as? UIImage {
            print("DEBUG:-ExtensionImage: we got something here..")
            self.image = photo
            return
        }
        
        guard let url = URL(string: urlString) else {
            print("DEBUG: no url converted...")
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let img = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageCache.setObject(img, forKey: urlString as NSString)
                        self?.image = img
                    }
                }
            }
        }
    }
    
    
}
