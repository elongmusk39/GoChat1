//
//  AuthViewController.swift
//  GoChat
//
//  Created by Long Nguyen on 7/29/21.
//

import UIKit

class AuthViewController: UIViewController {

//MARK: - Components
    
    private let backgroundView: UIImageView = {
        let vw = UIImageView()
        vw.clipsToBounds = true
        vw.contentMode = .scaleAspectFill
        vw.backgroundColor = .clear
        
        return vw
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.borderWidth = 0.67
        iv.layer.borderColor = UIColor.black.cgColor
        iv.clipsToBounds = true
        
        return iv
    }()
    
    private let welcomeLB: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        lb.textAlignment = .center
        lb.textColor = .white
        lb.text = "Welcome to GoChat"
        
        return lb
    }()
    
    private let signInButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(" Sign In with Google ", for: .normal)
        btn.backgroundColor = .white
        
        return btn
    }()
    
//MARK: - View Scenes
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .green
//        configureGradientLayer(from: 0, to: 2)
        configureUI()
    }
    
    
    func configureUI() {
        view.addSubview(backgroundView)
        backgroundView.frame = view.layer.frame
        backgroundView.image = #imageLiteral(resourceName: "greenGoChat")
        
        backgroundView.addSubview(iconImageView)
        iconImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 100, width: 200, height: 200)
        iconImageView.centerX(inView: view)
        iconImageView.image = #imageLiteral(resourceName: "tesla")
        
        backgroundView.addSubview(welcomeLB)
        welcomeLB.anchor(top: iconImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 32, paddingRight: 32)
        
        backgroundView.addSubview(signInButton)
        signInButton.anchor(top: welcomeLB.bottomAnchor, paddingTop: 20, height: 50)
        signInButton.centerX(inView: view)
    }
    
//MARK: - Actions
    
    
   

}
