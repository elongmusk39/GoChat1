//
//  ScrollViewController.swift
//  GoChat
//
//  Created by Long Nguyen on 7/29/21.
//

import UIKit
import Firebase

//this VC has 2 pages: CameraVC and ChatVC that switches back and forth

class ScrollViewController: UIViewController {

    let currentEmail = Auth.auth().currentUser?.email
    
    private let alphaBottomCamera: CGFloat = 0.67
    
    private var logOutObserver: NSObjectProtocol?
    private var logInObserver: NSObjectProtocol?
    private var scrollEnable: NSObjectProtocol?
    private var scrollDisable: NSObjectProtocol?
    
//MARK: - Components
    
    let horizontalScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
//        scrollView.backgroundColor = .red
        
        return scrollView
    }()
    
    private var segment: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["", "", ""])
        sc.backgroundColor = .clear
        
        //set the text color for the text of the sc
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        sc.selectedSegmentIndex = 1
        sc.selectedSegmentTintColor = UIColor.green
        
        return sc
    }()
    
    private let bottomView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .black
        return vw
    }()
    
    private let bottomCoverView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .black
        return vw
    }()
    
    private let cameraBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "camera"), for: .normal)
        btn.tintColor = .green
        btn.addTarget(self, action: #selector(switchToCameraVC), for: .touchUpInside)
        
        return btn
    }()
    
    private let chatBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "message"), for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(switchToChatVC), for: .touchUpInside)
        
        return btn
    }()
    
    private let mapBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "mappin.and.ellipse"), for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(switchToMapVC), for: .touchUpInside)
        
        return btn
    }()
    
    let mapVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical, options: [:])
    
    let cameraVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical, options: [:])
    
    let chatVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical, options: [:])
    
    
//MARK: - View Scenes
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .green
        horizontalScrollView.isScrollEnabled = true
        checkAuth()
        protocolVC()
        
        configureHoriScrollView()
        configureBottomView()
        
    }
    
    //gotta configure the bottom buttons here after the "bottomCover.frame.height" is set
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let bottomCover = bottomCoverView.frame.height
        configureBottomButton(viewCover: bottomCover)
    }
    
    //let's set default color for status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
    private func configureHoriScrollView() {
        view.addSubview(horizontalScrollView)
        horizontalScrollView.frame = view.bounds //fill entire screen
        
        //open to the left screen (directly to the camera on the left)
        horizontalScrollView.contentSize = CGSize(width: view.frame.width*3, height: view.frame.height)
        horizontalScrollView.contentInsetAdjustmentBehavior = .never //hide the nav bar above when launched
        horizontalScrollView.contentOffset = CGPoint(x: view.frame.width, y: 0)
        horizontalScrollView.delegate = self //for Extension ScrollView Delegate and protocol below
    }
    
    
    private func configureBottomView() {
        
        view.addSubview(bottomView)
        bottomView.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, height: 44)
        bottomView.alpha = alphaBottomCamera
        
        view.addSubview(bottomCoverView)
        bottomCoverView.anchor(top: bottomView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        bottomCoverView.alpha = alphaBottomCamera

        view.addSubview(segment)
//        segment.anchor(left: bottomView.leftAnchor, bottom: bottomView.bottomAnchor, right: bottomView.rightAnchor, height: 4)
        segment.anchor(top: bottomView.topAnchor, left: bottomView.leftAnchor, right: bottomView.rightAnchor, height: 2)
        segment.addTarget(self, action: #selector(segmentSwitch), for: .valueChanged)
        
    }
    
    private func configureBottomButton(viewCover: CGFloat) {
        let smallView = view.frame.width/3
        
        view.addSubview(mapBtn)
        mapBtn.frame = CGRect(
            x: (smallView-30)/2,
            y: view.frame.height-viewCover-44+2+8,
            width: 30, height: 26)
        
        view.addSubview(cameraBtn)
        cameraBtn.frame = CGRect(
            x: smallView + (smallView-32)/2,
            y: view.frame.height-viewCover-44+2+8,
            width: 32, height: 26)
        
        view.addSubview(chatBtn)
        chatBtn.frame = CGRect(
            x: 2*smallView + (smallView-30)/2,
            y: view.frame.height-viewCover-44+2+8,
            width: 30, height: 26)
    }
    

//MARK: - Protocols
    
    func protocolVC() {
        
        //protocol from SettingVC
        logOutObserver = NotificationCenter.default.addObserver(forName: .didLogOut, object: nil, queue: .main) { [weak self] _ in
            
            print("DEBUG-ScrollVC: logged out update notified, presenting LoginVC..")
            guard let strongSelf = self else { return }
            
            strongSelf.presentLoginVC()
        }
        
        //protocol from SettingVC
        logInObserver = NotificationCenter.default.addObserver(forName: .didLogIn, object: nil, queue: .main) { [weak self] _ in
            
            print("DEBUG-ScrollVC: login update notified, setting up CameraVC and ChatVC..")
            guard let strongSelf = self else { return }
            
            strongSelf.setUpMapVC()
            strongSelf.setUpCameraVC()
            strongSelf.setUpChatVC()
        }
        
        //protocol from ChatVC
        scrollEnable = NotificationCenter.default.addObserver(forName: .enableScroll, object: nil, queue: .main) { [weak self] _ in
            
            print("DEBUG-ScrollVC: scroll enabling notified..")
            guard let strongSelf = self else { return }
            strongSelf.horizontalScrollView.isScrollEnabled = true
            
        }
        
        //protocol from ChatVC
        scrollDisable = NotificationCenter.default.addObserver(forName: .disableScroll, object: nil, queue: .main) { [weak self] _ in
            
            print("DEBUG-ScrollVC: scroll disabling notified..")
            guard let strongSelf = self else { return }
            strongSelf.horizontalScrollView.isScrollEnabled = false
            
        }
        
    }
    
    //this func is exclusively unique for protocol
    deinit {
        if let observer1 = logOutObserver {
            NotificationCenter.default.removeObserver(observer1)
        }
        if let observer2 = logInObserver {
            NotificationCenter.default.removeObserver(observer2)
        }
        if let observer3 = scrollDisable {
            NotificationCenter.default.removeObserver(observer3)
        }
        if let observer4 = scrollEnable {
            NotificationCenter.default.removeObserver(observer4)
        }
        
    }
    
//MARK: - Actions
    
    private func hideOrShowBottomViews(alpha: CGFloat) {
        bottomView.alpha = alpha
        bottomCoverView.alpha = alpha
        segment.alpha = alpha
        mapBtn.alpha = alpha
        cameraBtn.alpha = alpha
        chatBtn.alpha = alpha
    }
    
    private func setUpTabButton(tintChat: UIColor, tintCam: UIColor, tintMap: UIColor, index: Int, alp: CGFloat) {
        chatBtn.tintColor = tintChat
        cameraBtn.tintColor = tintCam
        mapBtn.tintColor = tintMap
        segment.selectedSegmentIndex = index
        bottomView.alpha = alp
        bottomCoverView.alpha = alp
    }
    
    @objc func switchToChatVC() {
        horizontalScrollView.setContentOffset(CGPoint(x: 2*view.frame.width, y: 0), animated: false)
        chatBtn.tintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        cameraBtn.tintColor = .white
        mapBtn.tintColor = .white
        bottomView.alpha = 1
        bottomCoverView.alpha = 1
//        segment.selectedSegmentIndex = 1 //no need this one since "UIScrollViewDelegate" below is enough
    }
    
    @objc func switchToCameraVC() {
        horizontalScrollView.setContentOffset(CGPoint(x: view.frame.width, y: 0), animated: false)
        cameraBtn.tintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        chatBtn.tintColor = .white
        mapBtn.tintColor = .white
        bottomView.alpha = alphaBottomCamera
        bottomCoverView.alpha = alphaBottomCamera
//        segment.selectedSegmentIndex = 0
    }
    
    @objc func switchToMapVC() {
        horizontalScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        mapBtn.tintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        cameraBtn.tintColor = .white
        chatBtn.tintColor = .white
        bottomView.alpha = 1
        bottomCoverView.alpha = 1
//        segment.selectedSegmentIndex = 0
    }
    
    private func presentLoginVC() {
        DispatchQueue.main.async {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalTransitionStyle = .crossDissolve
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    private func checkAuth() {
        if currentEmail == nil || currentEmail == "nil" {
            print("DEBUG-ScrollVC: no user logged in")
            presentLoginVC()
        } else {
            guard let mail = currentEmail else { return }
            print("DEBUG-ScrollVC: \(mail) is currently logged in")
            setUpMapVC()
            setUpCameraVC()
            setUpChatVC()
        }
    }
    
    @objc func segmentSwitch() {
        if segment.selectedSegmentIndex == 0 {
            switchToMapVC()
        } else if segment.selectedSegmentIndex == 1 {
            switchToCameraVC()
        } else {
            switchToChatVC()
        }
    }
    
//MARK: - SetUp some VCs
    
    private func setUpMapVC() {
        let vc = MapViewController()
        vc.delegate = self
        mapVC.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
        
        horizontalScrollView.addSubview(mapVC.view)
        mapVC.view.frame = CGRect(x: 0, y: 0, width: horizontalScrollView.frame.width, height: horizontalScrollView.frame.height)
        addChild(mapVC) //add mapVC as a child to ScrollVC
        mapVC.didMove(toParent: self)
    }
    
    private func setUpCameraVC() {
        let vc = CameraViewController()
        cameraVC.setViewControllers([vc], direction: .forward, animated: false, completion: nil)

        horizontalScrollView.addSubview(cameraVC.view)
        cameraVC.view.frame = CGRect(x: view.frame.width, y: 0, width: horizontalScrollView.frame.width, height: horizontalScrollView.frame.height)
        addChild(cameraVC) //add cameraVC as a child to ScrollVC
        cameraVC.didMove(toParent: self)
    }
    
    private func setUpChatVC() {
        let vc = ChatViewController()
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        chatVC.setViewControllers([nav], direction: .forward, animated: false, completion: nil)
        
        horizontalScrollView.addSubview(chatVC.view)
        chatVC.view.frame = CGRect(x: 2*view.frame.width, y: 0, width: horizontalScrollView.frame.width, height: horizontalScrollView.frame.height)
        addChild(chatVC) //add chatVC as a child to ScrollVC
        chatVC.didMove(toParent: self)
    }
    

}

//MARK: - Extension ScrollView Delegate
//remember to write ".delegate = self" in ViewDidLoad
extension ScrollViewController: UIScrollViewDelegate {

    //this gets called whenever we touch or scroll the scrollView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let xCoor = scrollView.contentOffset.x
        
        if xCoor == 0 || xCoor < view.frame.width/2 {
            setUpTabButton(tintChat: .white, tintCam: .white, tintMap: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), index: 0, alp: 1)

        } else if xCoor > (view.frame.width/2) && xCoor < (3*view.frame.width/2) {
            setUpTabButton(tintChat: .white, tintCam: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), tintMap: .white, index: 1, alp: alphaBottomCamera)

        } else if xCoor > (3*view.frame.width/2) {
            setUpTabButton(tintChat: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), tintCam: .white, tintMap: .white, index: 2, alp: 1)
        }
        
    }
    

}

//MARK: - Protocol from ChatVC
//remember to write ".delegate = self" in ViewDidLoad
extension ScrollViewController: ChatViewControllerDelegate {
    func disableScroll() {
        print("DEBUG-ScrollVC: protocol from CHatVC, disable scroll")
        horizontalScrollView.isScrollEnabled = false
    }
    
    func enableScroll() {
        print("DEBUG-ScrollVC: protocol from CHatVC, enable scroll")
        horizontalScrollView.isScrollEnabled = true
    }
    
}

//MARK: - Protocol from MapVC
//remember to write ".delegate = self" in ViewDidLoad
extension ScrollViewController: MapViewControllerDelegate {
    func showBottomMap() {
        UIView.animate(withDuration: 0.2) {
            self.hideOrShowBottomViews(alpha: 0)
        }
    }
    
    func showBottomBar() {
        UIView.animate(withDuration: 0.2) {
            self.hideOrShowBottomViews(alpha: 1)
        }
    }
    
    
}
