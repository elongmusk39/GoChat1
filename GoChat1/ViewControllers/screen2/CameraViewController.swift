//
//  CameraViewController.swift
//  GoChat
//
//  Created by Long Nguyen on 7/29/21.
//

import UIKit
import Firebase
import AVFoundation //needed for building customizable camera
import MapKit //to get user current location

protocol CameraViewControllerDelegate: AnyObject {
    func switchToChatVC()
}

class CameraViewController: UIViewController {
    
    let topBtnDimension: CGFloat = 36
    private let userEmail = Auth.auth().currentUser?.email
    
    private var didCheckCameraPermission = false
    
    weak var delegate: CameraViewControllerDelegate? //for protocol
    private var changeUserInfoObserver: NSObjectProtocol?
    private var dismissLoading: NSObjectProtocol?
    
    private var loadingCaptureInfoArray = [Picture]()
    private var loadingCaptureImageArray = [UIImage]()
    private var imageSaveIndex = 0
    private var indexSaving = 0
    
//MARK: - Location components
    
    private var locationManager: CLLocationManager!
    private var latFull: Double = 0
    private var longFull: Double = 0
    private var alti: Double = 0
    private var city: String = "Unknown"
    private var place: String = "Unknown"
    private var state: String = "Unknown"
    private var county: String = "Unknown"
    private var country: String = "Unknown"
    private var zipcode: String = "Unknown"
    private var stName: String = "Unknown"
    private var stNo: String = "Unknown"
    
//MARK: - User and Photo Info
        
    //when "userInfo" got changed, the "didSet" got called. This var got filled with info fetched by func "fetchUserData"
    private var userInfo: User? {
        didSet {
            print("DEBUG-CameraVC: setting profile img...")
            profileImageView.sd_setImage(with: profileURL)
        }
    }
    
    private var profileURL: URL? {
        let urlString = userInfo?.profileImageUrl ?? "no url"
        print("DEBUG-CameraVC: return a profile img urlString")
        return URL(string: urlString)
    }
    
    private var ArrayAllPhoto = [Picture]()
    private var uiImageArr = [UIImage]()
    
//MARK: - Camera components
    
    //a session camera
    private var captureSession = AVCaptureSession()
    
    //toggle of camera
    private var backFacingCamera: AVCaptureDevice?
    private var frontFacingCamera: AVCaptureDevice?
    private var currentDevice: AVCaptureDevice?
    
    //output device
    private var stillImageOutput: AVCaptureStillImageOutput?
    private var stillImage: UIImage?
    
    //preview layer
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
//MARK: - Components
    
    private var loadingViewIndicator: UIView = {
        let vw = UIView()
        vw.layer.cornerRadius = 16
        vw.backgroundColor = .black.withAlphaComponent(0.37)
        
        return vw
    }()
    
    private let numberSavingBtnLb: UIButton = {
        let btn = UIButton()
        btn.setTitle("1", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        btn.setTitleColor(.red, for: .normal)
        btn.backgroundColor = .green
        return btn
    }()
    
    private let savingLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Images saving..."
        lb.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lb.textColor = .white
        
        return lb
    }()
    
    private let requestAccessLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Please allow us to access camera"
        lb.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        lb.textColor = .white
        lb.numberOfLines = .zero
        lb.textAlignment = .center
//        lb.adjustsFontSizeToFitWidth = true
        
        return lb
    }()
    
    private let goToSettingButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Go To Setting", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        btn.tintColor = .green
        btn.addTarget(self, action: #selector(goToSettingApp), for: .touchUpInside)
        
        return btn
    }()
    
    private let shutterButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = CGSize(width: 2, height: 2)
        btn.layer.shadowOpacity = 0.8
        
        return btn
    }()
    
    private let toggleCameraButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "arrow.triangle.2.circlepath.camera"), for: .normal)
        btn.tintColor = .white
        btn.contentMode = .scaleAspectFit
        btn.setDimensions(height: 24, width: 28)
        btn.addTarget(self, action: #selector(toggle), for: .touchUpInside)
        
        return btn
    }()
    
    private let libraryButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "photo.on.rectangle.angled"), for: .normal)
        btn.tintColor = .white
        btn.contentMode = .scaleAspectFit
        btn.setDimensions(height: 24, width: 28)
        btn.addTarget(self, action: #selector(showPhotoVC), for: .touchUpInside)
        
        return btn
    }()
    
    //gotta make it "lazy" to load the tap
    lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .white
        iv.image = UIImage(systemName: "person.circle")
        iv.layer.masksToBounds = true
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showSettingVC))
        iv.addGestureRecognizer(tap)
        
        return iv
    }()
    
    private let gridButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "rectangle.split.3x3"), for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(showGrid), for: .touchUpInside)
        
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = CGSize(width: 2, height: 2)
        btn.layer.shadowOpacity = 0.8
        
        return btn
    }()
    
    //MARK: - Grid
    
    private var verticalView1 = UIView()
    private var verticalView2 = UIView()
    private var horizontalView1 = UIView()
    private var horizontalView2 = UIView()
    
//MARK: - View Scenes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        checkLocationPermission() //after this, we check the Camera access
        protocolVC()
        
    }
    
    private func configureUIAndFetching() {
        configureGrid()
        setUpDecoyphotoVC()
        swipeGesture()
        
        //top components
        view.addSubview(profileImageView)
        profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, paddingTop: 4, paddingLeft: 12)
        profileImageView.setDimensions(height: topBtnDimension, width: topBtnDimension)
        profileImageView.layer.cornerRadius = topBtnDimension/2
        
        view.addSubview(gridButton)
        gridButton.anchor(top: profileImageView.topAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingRight: 12)
        gridButton.setDimensions(height: topBtnDimension, width: topBtnDimension)
        
        //loading indicator
        view.addSubview(loadingViewIndicator)
        loadingViewIndicator.anchor(left: profileImageView.rightAnchor, right: gridButton.leftAnchor, paddingLeft: 48, paddingRight: 48, height: 42)
        loadingViewIndicator.centerY(inView: profileImageView)
        loadingViewIndicator.isHidden = true
        
        loadingViewIndicator.addSubview(numberSavingBtnLb)
        numberSavingBtnLb.anchor(left: loadingViewIndicator.leftAnchor, paddingLeft: 12, width: 26, height: 26)
        numberSavingBtnLb.centerY(inView: loadingViewIndicator)
        numberSavingBtnLb.layer.cornerRadius = 26/2
        
        loadingViewIndicator.addSubview(savingLabel)
        savingLabel.anchor(left: numberSavingBtnLb.rightAnchor, paddingLeft: 12)
        savingLabel.centerY(inView: loadingViewIndicator)
        
        //bottom components
        view.addSubview(shutterButton)
        shutterButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 68) //bottomView (safe) is 44, so 24 above the tabBar
        shutterButton.centerX(inView: view)
        shutterButton.setDimensions(height: 90, width: 90)
        shutterButton.layer.cornerRadius = 90/2
        
        view.addSubview(toggleCameraButton)
        toggleCameraButton.anchor(left: shutterButton.rightAnchor, paddingLeft: 20)
        toggleCameraButton.centerY(inView: shutterButton)
        
        view.addSubview(libraryButton)
        libraryButton.anchor(right: shutterButton.leftAnchor, paddingRight: 20)
        libraryButton.centerY(inView: shutterButton)
        
        //now fetch user info and photo info
        fetchUserData()
        fetchAllPhotos()
    }
    
    private func configureGrid() {
        verticalView1.backgroundColor = .white
        verticalView2.backgroundColor = .white
        horizontalView1.backgroundColor = .white
        horizontalView2.backgroundColor = .white

        view.addSubview(verticalView1)
        let d1 = (view.frame.width-2)/3
        verticalView1.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingLeft: d1, paddingBottom: 44, width: 1)
        verticalView1.isHidden = true

        view.addSubview(verticalView2)
        let d2 = 1+2*d1
        verticalView2.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingLeft: d2, paddingBottom: 44, width: 1)
        verticalView2.isHidden = true

        view.addSubview(horizontalView1)
        let d3 = (view.frame.height-2-44)/3 //44 is the height of customize tabBar
        horizontalView1.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: d3, height: 1)
        horizontalView1.isHidden = true

        view.addSubview(horizontalView2)
        let d4 = 1+2*d3
        horizontalView2.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: d4, height: 1)
        horizontalView2.isHidden = true
    }
    
    //this func will load the PhotoVC in the backgound, so it will load faster when use need
    private func setUpDecoyphotoVC() {
//        let vc = LoadingViewController()
//        vc.delegate = self //enable protocol
//        vc.navigationController?.navigationBar.isHidden = false
//        vc.view.alpha = 0.5 //hide it
//
//        view.addSubview(vc.view)
//        vc.view.frame = CGRect(x: 0, y: view.frame.height-300, width: view.frame.width, height: view.frame.height)
//        addChild(vc) //add cameraVC as a child to ScrollVC
//        vc.didMove(toParent: self)
    }
    
    
//MARK: - Protocols Observer
    
    func protocolVC() {
        //protocol from SettingVC
        changeUserInfoObserver = NotificationCenter.default.addObserver(forName: .didChangeUserInfo, object: nil, queue: .main) { [weak self] _ in
            
            print("DEBUG-CameraVC: protocol from SettingVC, change userInfo")
            guard let strongSelf = self else { return }
            strongSelf.fetchUserData()
        }
        
    }
    
    
    //this func is exclusively unique for protocol
    deinit {
        if let observer1 = changeUserInfoObserver {
            NotificationCenter.default.removeObserver(observer1)
        }
    }
    
//MARK: - Actions
    
    private func swipeGesture() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(showPhotoVC))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
    }
    
    private func showSavingIndicatorLabel(show: Bool) {
        loadingViewIndicator.isHidden = !show
        numberSavingBtnLb.setTitle("\(indexSaving)", for: .normal)
    }
    
    private func showNavVC(viewController: UIViewController, style: UIModalTransitionStyle) {
        let vc = viewController
        let nav = UINavigationController(rootViewController: vc)
        nav.modalTransitionStyle = style
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    @objc func showPhotoVC() {
        let vc = ImagesViewController()
        showNavVC(viewController: vc, style: .coverVertical)
    }
    
    @objc func showGrid() {
        verticalView1.isHidden = !verticalView1.isHidden
        verticalView2.isHidden = !verticalView2.isHidden
        horizontalView1.isHidden = !horizontalView1.isHidden
        horizontalView2.isHidden = !horizontalView2.isHidden
    }
    
    @objc func showSettingVC() {
        let vc = SettingViewController()
        showNavVC(viewController: vc, style: .coverVertical)
    }
    
    @objc func goToSettingApp() {
        UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!) //open the app setting
    }
    
    private func fetchUserData() {
        //let's fill in with data
        FetchingStuff.fetchUserInfo(currentEmail: userEmail ?? "mail") { userStuff in
            self.userInfo = userStuff //pass in the data
            print("DEBUG-CameraVC: done fetching user info")
        }
        
    }
    
    private func fetchAllPhotos() {
        print("DEBUG-CameraVC: fetching all images...")
        guard let userMail = self.userEmail else { return }
        
        FetchingStuff.fetchPhotos(email: userMail) { pictureArray in
            self.ArrayAllPhoto = pictureArray
            self.deleteNonSensePhoto()
        }
    }
    
    private func deleteAnInfo(timeTaken: String) {
        showLoadingView(true)
        guard let email = self.userEmail else { return }
        Firestore.firestore().collection("users").document(email).collection("library").document(timeTaken).delete { error in
            
            if let e = error?.localizedDescription {
                self.showLoadingView(false, message: "Deleting..")
                self.alert(error: e, buttonNote: "Try again")
                return
            }
            self.showLoadingView(false)
        }
    }
    
    private func deleteNonSensePhoto() {
        guard ArrayAllPhoto.count != 0 else { return }
        
        for idx in 0...ArrayAllPhoto.count-1 {
            if ArrayAllPhoto[idx].imageUrl == "no url" {
                deleteAnInfo(timeTaken: ArrayAllPhoto[idx].timestamp)
            }
        }
        print("DEBUG-CameraVC: after trash, we have \(ArrayAllPhoto.count) photos")
    }
    
//MARK: - Configure Camera
    
    private func configureCamera() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        //setup the camera for 2 modes (front and back)
        let devicesArray = AVCaptureDevice.devices(for: AVMediaType.video)
        for device in devicesArray {
            if device.position == .back {
                backFacingCamera = device
            } else if device.position == .front {
                frontFacingCamera = device
            }
        }
        
        //default device
        currentDevice = backFacingCamera
        
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecType.jpeg]
        
        do {
            //cannot execute the line below on a simulator
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            
            captureSession.addInput(captureDeviceInput)
            captureSession.addOutput(stillImageOutput!)
            
            //setup camera preview layer
            cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession) //add "guard" if possible
            
            //let take care the UI
            view.layer.addSublayer(cameraPreviewLayer!)
            cameraPreviewLayer?.videoGravity = .resizeAspectFill
            cameraPreviewLayer?.frame = view.layer.frame
            //            view.bringSubviewToFront(captureButton) //bring it to front to show it on the UI (we actually dont need this)
            captureSession.startRunning()
            
        } catch let error {
            print("DEBUG-CameraVC: error camera - \(error)")
        }
        
    }
    
    private func doubleTapToToggleCam() {
        let tapView = UIView()
        tapView.backgroundColor = .clear
        view.addSubview(tapView)
        tapView.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, bottom: shutterButton.topAnchor, right: view.rightAnchor)
        
        let toggleCameraTap = UITapGestureRecognizer()
        toggleCameraTap.numberOfTapsRequired = 2
        toggleCameraTap.addTarget(self, action: #selector(toggle))
        tapView.addGestureRecognizer(toggleCameraTap)
        
    }
    
    @objc func toggle() {
        print("DEBUG-CameraVC: toggling camera..")
        
        captureSession.beginConfiguration()
        guard let newDevice = (currentDevice?.position == .back) ? frontFacingCamera : backFacingCamera else { return }
        
        //let's remove all sessions from the current camera state (remove all front Cam sessions to begin back Cam, vice versa)
        for input in captureSession.inputs {
            captureSession.removeInput(input as! AVCaptureDeviceInput)
        }
        
        let cameraInput: AVCaptureDeviceInput
        do {
            cameraInput = try AVCaptureDeviceInput(device: newDevice)
        } catch let error {
            print("DEBUG: error toggle camera - \(error)")
            return
        }
        
        if captureSession.canAddInput(cameraInput) {
            captureSession.addInput(cameraInput)
        }
        
        //now change the camera direction
        currentDevice = newDevice
        captureSession.commitConfiguration()
    }
    
    private func takePhotoAnimation() {
        shutterButton.backgroundColor = .white
        self.shutterButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
            self.shutterButton.isEnabled = true
        })
        
        UIView.animate(withDuration: 0.3) {
            self.shutterButton.alpha = 0
            self.view.alpha = 0
        } completion: { _ in
            self.shutterButton.backgroundColor = .clear
            UIView.animate(withDuration: 0.3) {
                self.shutterButton.alpha = 1
                self.view.alpha = 1
            }
        }
        
    }
    
    @objc func takePhoto() {
        print("DEBUG-CameraVC: shutter button tapped, uploading Photo..")
        takePhotoAnimation()
            
        guard let videoConnection = stillImageOutput?.connection(with: AVMediaType.video) else { return }

        //let's capture the photo
        stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { imageDataBuffer, error in

            if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer!) {

                if self.currentDevice == self.frontFacingCamera {
                    //this is only for front facing camera (gotta mirror it)
                    print("DEBUG-CameraVC: taking photo from selfie cam")
                    let img = UIImage(data: imageData)
                    let image = UIImage(cgImage: (img?.cgImage)!, scale: 1.0, orientation: .leftMirrored)
                    self.stillImage = image //pass the modified image to "stillImage"
                } else {
                    //this is simply for back facing camera
                    print("DEBUG-CameraVC: taking photo from back cam")
                    self.stillImage = UIImage(data: imageData) //pass the captured image to "stillImage"
                }
                //show the capture picture
//                self.captureSession.stopRunning()
                self.uploadLocationAndImage()
            }
        })
    }
    
//MARK: - Mark Location
    
    private func currentLocation() {
        print("DEBUG-CameraVC: locating current...")
        guard let lat = locationManager.location?.coordinate.latitude else { return }
        guard let long = locationManager.location?.coordinate.longitude else { return }
        
        //showing the address (we got an extension (LocationAddress) for this)
        let location = CLLocation(latitude: lat, longitude: long)
        location.placemark { placemark, error in
            if let e = error?.localizedDescription {
                print("DEBUG-CameraVC: error locating \(e)")
                return
            }
            guard let pin = placemark else { return }
            //guard let address = pin.postalAddressFormatted else { return }
            guard let cty = pin.city else { return }
            guard let adArea = pin.administrativeArea?.description else { return }
            guard let street = pin.streetName else { return }
            let placeName = pin.subLocality ?? "-"
            
            print("DEBUG-CameraVC: done locating - \(street) \(cty), \(placeName), \(adArea)")
        }
    }
    
//MARK: - Upload Location, Image
    
    //gotta use func "checkLocationPermission" to access current lat and long
    private func uploadLocationAndImage() {
        guard let capturePhoto = stillImage else { return }
        guard let lat = locationManager.location?.coordinate.latitude else { return }
        guard let long = locationManager.location?.coordinate.longitude else { return }
        guard let alt = locationManager.location?.altitude else { return } //in meter
        
        let location = CLLocation(latitude: lat, longitude: long)
        location.placemark { placemark, error in
            if let e = error?.localizedDescription {
                print("DEBUG-CameraVC: error locating \(e)")
                return
            }
            guard let pin = placemark else { return }
            //guard let address = pin.postalAddressFormatted else { return }
            let cty = pin.city ?? "unknown"
            let adArea = pin.administrativeArea?.description ?? "unknown"
            let cnty = pin.county ?? "unknown"
            let ctry = pin.country ?? "unknown"
            let zipCode = pin.zipCode ?? "unknown"
            let streetNo = pin.streetNumber ?? "unknown"
            let street = pin.streetName ?? "unknown"
            let placeName = pin.subLocality ?? "-"
            print("DEBUG-CameraVC: finish processing location")
            
            Time.configureTime { timeArr in
                let dict = [
                    "latitude": lat,
                    "longitude": long,
                    "altitude": alt,
                    "country": ctry,
                    "county": cnty,
                    "city": cty,
                    "state": adArea,
                    "streetName": street,
                    "streetNumber": streetNo,
                    "zipcode": zipCode,
                    "placeName": placeName,
                    "timestamp": timeArr[0],
                    "date": timeArr[1],
                    "imageURL": "no url"
                ] as [String : Any]
                
                let newSaveImg = Picture(dictionary: dict)
                self.loadingCaptureInfoArray.append(newSaveImg)
                self.loadingCaptureImageArray.append(capturePhoto)
                self.indexSaving = self.indexSaving + 1
                self.updateLoadingImage(data: dict)
            }
        }
      
    } //end of func
    
    private func updateLoadingImage(data: [String: Any]) {
        print("DEBUG-CameraVC: we have \(loadingCaptureInfoArray.count) photos uploading..")
        showSavingIndicatorLabel(show: true)
        imageSaveIndex = loadingCaptureInfoArray.count-1
        guard let email = userEmail else { return }
        
        UploadInfo.uploadLocationAndPhoto(userMail: email, takenImage: loadingCaptureImageArray[imageSaveIndex], photoInfo: loadingCaptureInfoArray[imageSaveIndex], dictionary: data) { error in
            
            if let e = error?.localizedDescription {
                self.alert(error: e, buttonNote: "OK")
                return
            }
            self.indexSaving = self.indexSaving - 1
            self.numberSavingBtnLb.setTitle("\(self.indexSaving)", for: .normal)
            print("DEBUG-CameraVC: we have \(self.loadingCaptureImageArray.count) photos in uploading array")
            
//            self.fetchAllPhotos() //get ready for PhotoVC
            self.indexSaving == 0 ? self.showSavingIndicatorLabel(show: false) : self.showSavingIndicatorLabel(show: true)
            
            //send notifi to MapVC
            NotificationCenter.default.post(name: .refreshMap, object: nil)
        }
    }
    
//MARK: - Privacy camera
    
    private func setUpCameraAndUIAndLocation() {
        locationManager?.startUpdatingLocation()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest //get current user's location and zoom into it
        currentLocation() //let's extract the address base on lat and long
        
        configureCamera()
        configureUIAndFetching()
        doubleTapToToggleCam()
    }
    
    private func showLabelAccess(show: Bool, message: String) {
        //in case camera, location, micro is not accessed
        view.addSubview(goToSettingButton)
        goToSettingButton.centerY(inView: view)
        goToSettingButton.centerX(inView: view)
        
        view.addSubview(requestAccessLabel)
        requestAccessLabel.anchor(left: view.leftAnchor, bottom: goToSettingButton.topAnchor, right: view.rightAnchor, paddingLeft: 20, paddingBottom: 12, paddingRight: 20)
        requestAccessLabel.centerX(inView: view)
        requestAccessLabel.text = message
        
        requestAccessLabel.isHidden = !show
        goToSettingButton.isHidden = !show
    }
    
    private func checkCameraPermissions() {
        didCheckCameraPermission = true
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        
        case .notDetermined:
            //let's request it
            print("DEBUG-CameraVC: camera access is notDetermined")
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted == true {
                    DispatchQueue.main.async {
                        print("DEBUG-CameraVC: camera access granted")
                        self?.showLabelAccess(show: false, message: "None")
//                        self?.setUpCameraAndUIAndLocation()
                        self?.configureUIAndFetching()
                        self?.currentLocation()
                    }
                } else {
                    DispatchQueue.main.async {
                        print("DEBUG-CameraVC: camera access rejected")
                        self?.showLabelAccess(show: true, message: "Please allow to access Camera")
                    }
                }
                
            }
        case .restricted, .denied:
            print("DEBUG-CameraVC: camera access is restricted/denied")
            configureUIAndFetching()
            showLabelAccess(show: true, message: "Please allow to access Camera")
        case .authorized:
            print("DEBUG-CameraVC: camera access is authorized")
            self.showLabelAccess(show: false, message: "None")
//            self.setUpCameraAndUIAndLocation()
            self.configureUIAndFetching()
            self.currentLocation()
        @unknown default:
            break
        }
    }
    
    
}

    

//MARK: - Privacy Location
//remember to modify the info.plist (go to Notes to see details) before writing these codes, otherwise it crashes
extension CameraViewController: CLLocationManagerDelegate {
    
    //this func will check the location status of the app
    func checkLocationPermission() {
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        
        case .notDetermined:
            print("DEBUG-CameraVC: location notDetermined")
            locationManager.requestAlwaysAuthorization()
        case .restricted, .denied:
            print("DEBUG-CameraVC: location restricted/denied")
            configureUIAndFetching()
            showLabelAccess(show: true, message: "Please allow to access Location")
            break
        case .authorizedAlways, .authorizedWhenInUse: //so this app on simulator only works in case of "authorizedAlways", in real app, we can modify it
            print("DEBUG-CameraVC: location access is always/WhenInUse")
            checkCameraPermissions()
            
        @unknown default:
            print("DEBUG: location default")
            break
        }
    }
    
    //let's evaluate the location status, it activates after we done picking a case in func "checkLocationPermission" and whenever we open the app
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            print("DEBUG-CameraVC: current location status is whenInUse")
            if didCheckCameraPermission {
                print("DEBUG-CameraVC: did check CameraPermission, no need to check it again")
            } else {
                checkCameraPermissions()
            }
            
        } else if status == .authorizedAlways {
            print("DEBUG-CameraVC: current location status is always")
            if didCheckCameraPermission {
                print("DEBUG-CameraVC: already check CameraPermission, no need to check it again")
            } else {
                checkCameraPermissions()
            }
            
        } else if status == .denied {
            print("DEBUG-CameraVC: current location status is denied")
            configureUIAndFetching()
            showLabelAccess(show: true, message: "Please allow to access Location")
        }
    }
}


