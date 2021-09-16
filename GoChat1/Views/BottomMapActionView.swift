//
//  BottomMapActionView.swift
//  GoChat1
//
//  Created by Long Nguyen on 9/12/21.
//

import UIKit

protocol BottomMapActionViewDelegate: AnyObject {
    func sendTo()
    func zoomIn()
    func zoomOut()
    func dismiss()
    func share()
}

class BottomMapActionView: UIView {
    
    weak var delegate: BottomMapActionViewDelegate?
    
//MARK: - PictView Components
    
    private let coverImgView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .white.withAlphaComponent(0.2)
        
        return vw
    }()
    
    private let pictView: UIImageView = {
        let iv = UIImageView() //we dont need contentMode here
        iv.image = #imageLiteral(resourceName: "greenGoChat")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        
        return iv
    }()
    
    private let photoNoLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lb.text = "Total: 100 photos"
        lb.textAlignment = .center
        lb.textColor = .lightGray
        
        return lb
    }()
    
    private let arrowIndicator: UIImageView = {
        let iv = UIImageView() //we dont need contentMode here
        iv.image = UIImage(systemName: "chevron.right.circle")
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .green
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        
        return iv
    }()
    
//MARK: - Button Components
    
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
        
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(1)
        alpha = 0
        
        //buttons
        let stackBottom = UIStackView(arrangedSubviews: [shareToLabel, zoomOutLabel, dismissLabel, zoomInLabel, sendToLabel])
        stackBottom.axis = .horizontal
        stackBottom.distribution = .equalSpacing
        stackBottom.alignment = .center
        addSubview(stackBottom)
        stackBottom.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingLeft: 12, paddingRight: 12, height: 18)
        
        let stackTop = UIStackView(arrangedSubviews: [shareToButton, zoomOutButton, dismissButton, centerButton, sendToButton])
        stackTop.axis = .horizontal
        stackTop.distribution = .equalSpacing
        stackTop.alignment = .center
        addSubview(stackTop)
        stackTop.anchor(left: leftAnchor, bottom: stackBottom.topAnchor, right: rightAnchor, paddingLeft: 12, paddingBottom: 2, paddingRight: 12, height: 30)
        
        //picture view
        addSubview(coverImgView)
        coverImgView.anchor(top: topAnchor, left: leftAnchor, bottom: stackTop.topAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 16, paddingBottom: 12, paddingRight: 16)
        coverImgView.layer.cornerRadius = 8
        
        coverImgView.addSubview(pictView)
        pictView.anchor(top: coverImgView.topAnchor, left: coverImgView.leftAnchor, bottom: coverImgView.bottomAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, width: 40)
        pictView.centerY(inView: coverImgView)
        pictView.layer.cornerRadius = 4
        
        coverImgView.addSubview(photoNoLabel)
        photoNoLabel.anchor(left: pictView.rightAnchor, paddingLeft: 8)
        photoNoLabel.centerY(inView: pictView)
        
        coverImgView.addSubview(arrowIndicator)
        arrowIndicator.anchor(right: coverImgView.rightAnchor, paddingRight: 12, width: 30, height: 30)
        arrowIndicator.centerY(inView: pictView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//MARK: - Actions
    
    @objc func dismissVC() {
        delegate?.dismiss()
    }
    
    @objc func zoomInAnno() {
        delegate?.zoomIn()
    }
    
    @objc func zoomOutAnnos() {
        delegate?.zoomOut()
    }
    
    @objc func sharing() {
        delegate?.share()
    }
    
    @objc func sending() {
        delegate?.sendTo()
    }
    
}
