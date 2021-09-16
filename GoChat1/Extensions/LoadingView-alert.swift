//
//  LoadingView-alert.swift
//  GoChat
//
//  Created by Long Nguyen on 8/3/21.
//

import UIKit

extension UIViewController {
    
    func showLoadingView(_ present: Bool, message: String? = nil) {
        
        if present {
            let vw = UIView()
            vw.frame = self.view.frame
            //vw.frame = CGRect(x: (self.view.frame.width-150)/2, y: (self.view.frame.height-150)/2, width: 150, height: 150)
            //vw.layer.cornerRadius = 20
            vw.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.6)
            vw.tag = 1
            
            
            let indicator = UIActivityIndicatorView()
            indicator.style = .whiteLarge
            indicator.center = vw.center
            
            
            let lb = UILabel()
            lb.text = message
            lb.font = UIFont.systemFont(ofSize: 20)
            lb.textColor = .white
            lb.textAlignment = .center
            lb.alpha = 0.87
            
            view.addSubview(vw)
            vw.addSubview(indicator)
            vw.addSubview(lb)
            
            lb.centerX(inView: vw)
            lb.anchor(top: indicator.bottomAnchor, paddingTop: 32)
            
            indicator.startAnimating()
            
        } else {
            view.subviews.forEach { subview in
                if subview.tag == 1 {
                    UIView.animate(withDuration: 0.5) {
                        subview.alpha = 0
                    } completion: { _ in
                        subview.removeFromSuperview()
                    }
                    
                }
            }
        }
    }
    
    //let do some alerts
    func alert (error: String, buttonNote: String) {
        let alert = UIAlertController (title: "Error!!", message: "\(error)", preferredStyle: .alert)
        let tryAgain = UIAlertAction (title: buttonNote, style: .cancel, handler: nil)
                
        alert.addAction(tryAgain)
        present (alert, animated: true, completion: nil)
    }
    
    
    
}
