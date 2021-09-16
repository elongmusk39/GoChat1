//
//  ChatHeader.swift
//  GoChat
//
//  Created by Long Nguyen on 7/30/21.
//

import UIKit

protocol ChatHeaderDelegate: AnyObject {
    func activateSearch()
    func presentSettingVC()
}

class ChatHeader: UIView {
    
    let btnDimension: CGFloat = 36
    
    weak var delegate: ChatHeaderDelegate?
    
    //when "userInfo" got changed, the "didSet" got called. This var got filled with info fetched by func "fetchUserData"
    var userInfo: User? {
        didSet {
            profileImageView.sd_setImage(with: profileURL)
        }
    }
    
    private var profileURL: URL? {
        let urlString = userInfo?.profileImageUrl ?? "no url"
        print("DEBUG-Header: profile urlString is \(urlString)")
        return URL(string: urlString)
    }
    
//MARK: - Components
        
    //gotta make it "lazy" to load the tap
    lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .green
        iv.image = UIImage(systemName: "person.circle")
        iv.layer.masksToBounds = true
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showSettingVC))
        iv.addGestureRecognizer(tap)
        
        return iv
    }()
    
    private let searchButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.contentMode = .scaleAspectFit
        btn.setBackgroundImage(UIImage(systemName: "magnifyingglass.circle"), for: .normal)
        btn.tintColor = .green
        btn.addTarget(self, action: #selector(enableSearch), for: .touchUpInside)
        
        return btn
    }()
    
    //gotta make this "lazy var" to load the tap gesture
    private let chatLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Chat"
        lb.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        lb.textColor = .white
        lb.textAlignment = .center
        //lb.adjustsFontSizeToFitWidth = true
        
        return lb
    }()
    
    private let addButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.contentMode = .scaleAspectFit
        btn.setBackgroundImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        btn.tintColor = .green
        
        return btn
    }()
    
//MARK: - View Scenes
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: safeAreaLayoutGuide.topAnchor, left: safeAreaLayoutGuide.leftAnchor, paddingTop: 8, paddingLeft: 8, width: btnDimension, height: btnDimension)
        profileImageView.layer.cornerRadius = btnDimension/2
        
        addSubview(searchButton)
        searchButton.anchor(left: profileImageView.rightAnchor, paddingLeft: 12, width: btnDimension, height: btnDimension)
        searchButton.centerY(inView: profileImageView)
        
        addSubview(addButton)
        addButton.anchor(right: safeAreaLayoutGuide.rightAnchor, paddingRight: 8, width: btnDimension+2, height: btnDimension)
        addButton.centerY(inView: profileImageView)
        
        addSubview(chatLabel)
        chatLabel.centerY(inView: self)
        chatLabel.centerX(inView: self)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//MARK: - Actions
    
    @objc func showSettingVC() {
        print("DEBUG-ChatHeader: profileImageView tapped..")
        delegate?.presentSettingVC()
    }
    
    @objc func enableSearch() {
        print("DEBUG-ChatHeader: searchButton tapped..")
        delegate?.activateSearch()
    }
    
    
    
}
