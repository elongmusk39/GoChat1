//
//  MapBottomView.swift
//  GoChat
//
//  Created by Long Nguyen on 8/14/21.
//

import UIKit

protocol MapBottomViewDelegate: AnyObject {
    func dismissMapPhoto()
    func zoomIn()
    func zoomOut()
    func sendTo()
    func shareTo()
}

class MapBottomView: UIView {
    
    weak var delegate: MapBottomViewDelegate?
    
//MARK: - Components
    
    private let dismissButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "xmark.circle"), for: .normal)
        btn.tintColor = .white
        btn.contentMode = .scaleAspectFit
        btn.setDimensions(height: 26, width: 26)
        btn.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        return btn
    }()
    
    private let dismissLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Dismi"
        lb.alpha = 0
        lb.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lb.textColor = .green
        
        return lb
    }()
    
    
    private let centerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "camera.metering.center.weighted"), for: .normal)
        btn.tintColor = .green
        btn.contentMode = .scaleAspectFit
        btn.setDimensions(height: 28, width: 28)
        btn.addTarget(self, action: #selector(zoomInAnno), for: .touchUpInside)
        
        return btn
    }()
    
    private let zoomInLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Center"
        lb.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lb.textColor = .green
        
        return lb
    }()
    
    private let zoomOutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "minus.magnifyingglass"), for: .normal)
        btn.tintColor = .green
        btn.contentMode = .scaleAspectFit
        btn.setDimensions(height: 28, width: 28)
        btn.addTarget(self, action: #selector(zoomOutAnnos), for: .touchUpInside)
        
        return btn
    }()
    
    private let zoomOutLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Zoom"
        lb.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lb.textColor = .green
        
        return lb
    }()
    
    private let sendToButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "arrowshape.turn.up.right"), for: .normal)
        btn.tintColor = .green
        btn.contentMode = .scaleAspectFit
        btn.setDimensions(height: 28, width: 28)
        btn.addTarget(self, action: #selector(sending), for: .touchUpInside)
        
        return btn
    }()
    
    private let sendToLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Send"
        lb.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lb.textColor = .green
        
        return lb
    }()
    
    private let shareToButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        btn.tintColor = .green
        btn.contentMode = .scaleAspectFit
        btn.setDimensions(height: 28, width: 28)
        btn.addTarget(self, action: #selector(sharing), for: .touchUpInside)
        
        return btn
    }()
    
    private let shareToLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Share"
        lb.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lb.textColor = .green
        
        return lb
    }()
    
//MARK: - View scenes
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.67)
        
        let stackTop = UIStackView(arrangedSubviews: [shareToButton, zoomOutButton, dismissButton, centerButton, sendToButton])
        stackTop.axis = .horizontal
        stackTop.distribution = .equalSpacing
        stackTop.alignment = .center
        addSubview(stackTop)
        stackTop.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 2, paddingLeft: 12, paddingRight: 12, height: 30)
        
        let stackBottom = UIStackView(arrangedSubviews: [shareToLabel, zoomOutLabel, dismissLabel, zoomInLabel, sendToLabel])
        stackBottom.axis = .horizontal
        stackBottom.distribution = .equalSpacing
        stackBottom.alignment = .center
        addSubview(stackBottom)
        stackBottom.anchor(top: stackTop.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingLeft: 12, paddingRight: 12, height: 18)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//MARK: - Actions
    
    @objc func dismissVC() {
        delegate?.dismissMapPhoto()
    }
    
    @objc func zoomInAnno() {
        delegate?.zoomIn()
    }
    
    @objc func zoomOutAnnos() {
        delegate?.zoomOut()
    }
    
    @objc func sharing() {
        delegate?.shareTo()
    }
    
    @objc func sending() {
        delegate?.sendTo()
    }
    
    
    
}
