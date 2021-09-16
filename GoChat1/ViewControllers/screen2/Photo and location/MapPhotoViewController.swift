//
//  MapViewController.swift
//  GoChat
//
//  Created by Long Nguyen on 8/13/21.
//

import UIKit
import MapKit
import SDWebImage

private let annoID = "photoIdentifier"

class MapPhotoViewController: UIViewController {
    
    var currentEmail = "" //got filled in PhotoVC
    var fromSearch = false
    private var timePhoto = ""
    private var didAddPhotoAnno = true
    
    var photoLocationInfo: Picture? {
        didSet {
            configureInfo()
            imageAnno.sd_setImage(with: imageURL)
        }
    }
    
    private var imageURL: URL? {
        return URL(string: photoLocationInfo?.imageUrl ?? "no url")
    }
    
    //this var is added into the annotation view
    private var imageAnno: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .green
        iv.isUserInteractionEnabled = true
        
        iv.layer.cornerRadius = 12
        
        return iv
    }()
    
    private let mapView = MKMapView()
    private var locationManager: CLLocationManager!
    private var route: MKRoute? //use this to generate polyline
    
//MARK: - Top Components
    
    private var titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Westminster, CA"
        lb.numberOfLines = .zero
        lb.textAlignment = .center
        lb.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        
        return lb
    }()
    
    private let infoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "info.circle"), for: .normal)
        btn.tintColor = .black
        btn.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(showInfo), for: .touchUpInside)
        
        return btn
    }()
    
//MARK: - Info labels
    
    private lazy var infoView: UIView = {
        let vw = UIView()
        vw.layer.cornerRadius = 8
        vw.backgroundColor = .black
        
        return vw
    }()
    
    //make it a lazy var since we are using a func in the Helpers section
    private lazy var altitudeLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = .zero
        lb.textAlignment = .center
        lb.adjustsFontSizeToFitWidth = true
        lb.attributedText = attributedStatText(label: "Altitude: ", value: "10m")
        
        return lb
    }()
    
    //make it a lazy var since we are using a func in the Helpers section
    private lazy var distanceLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = .zero
        lb.textAlignment = .center
        lb.adjustsFontSizeToFitWidth = true
        lb.attributedText = attributedStatText(label: "Distance: ", value: "12m")
        
        return lb
    }()
    
    //make it a lazy var since we are using a func in the Helpers section
    private lazy var addressLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = .zero
        lb.textAlignment = .center
        lb.adjustsFontSizeToFitWidth = true
        lb.attributedText = attributedStatText(label: "Address: ", value: "12m")
        
        return lb
    }()
    
    //make it a lazy var since we are using a func in the Helpers section
    private lazy var countryLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = .zero
        lb.textAlignment = .center
        lb.adjustsFontSizeToFitWidth = true
        lb.attributedText = attributedStatText(label: "Country: ", value: "12m")
        
        return lb
    }()
    
    private lazy var countyLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = .zero
        lb.textAlignment = .center
        lb.adjustsFontSizeToFitWidth = true
        lb.attributedText = attributedStatText(label: "County: ", value: "12m")
        
        return lb
    }()
    
    private lazy var stateLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = .zero
        lb.textAlignment = .center
        lb.adjustsFontSizeToFitWidth = true
        lb.attributedText = attributedStatText(label: "state: ", value: "12m")
        
        return lb
    }()
    
    private lazy var timeLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = .zero
        lb.textAlignment = .center
        lb.adjustsFontSizeToFitWidth = true
        lb.attributedText = attributedStatText(label: "Time: ", value: "12m")
        
        return lb
    }()
    
    private lazy var stackInfo: UIStackView = {
        let st = UIStackView(arrangedSubviews: [distanceLabel, altitudeLabel, addressLabel, stateLabel, countyLabel, countryLabel, timeLabel])
        st.axis = .vertical
        st.distribution = .equalSpacing
        st.alignment = .leading
        st.spacing = 6
        
        return st
    }()
    
    
//MARK: - Bottom Components
    
    private let openMapButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Open Map", for: .normal)
        btn.backgroundColor = .black
        btn.tintColor = .green
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.green.cgColor
        btn.layer.cornerRadius = 12
        
        btn.addTarget(self, action: #selector(openMapButtonTapped), for: .touchUpInside)
        
        return btn
    }()
    
    private let bottomView = MapBottomView()
    
    private let bottomCover: UIView = {
        let vw = UIView()
        vw.backgroundColor = .black
        vw.alpha = 0.67
        return vw
    }()
    
    
    
//MARK: - View Scenes
    
    //gotta have the init for "flowLayout" cuz the PhotoController will call out this MapPhotoVC
    init(timeOfPhoto: String) {
        self.timePhoto = timeOfPhoto //assign value fetched from PhotoController, including documentID (just like an uid for each each post)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        checkLocationPermission()
        configureUI()
        navigationItem.title = "Location"
        
        showLoadingView(true, message: "Loading..")
        configureMapView()
        fetchPhotoData()
    }
    
    //let's set default color for status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    private func configureUI() {
        
        //infoBtn and title
        mapView.addSubview(infoButton)
        infoButton.anchor(top: mapView.safeAreaLayoutGuide.topAnchor, left: mapView.leftAnchor, paddingTop: 8, paddingLeft: 12, width: 24, height: 24)
        
        mapView.addSubview(titleLabel)
        titleLabel.anchor(left: infoButton.rightAnchor, right: mapView.rightAnchor, paddingLeft: 12, paddingRight: 12+24+12)
        titleLabel.centerY(inView: infoButton)
        
        //info label
        mapView.addSubview(infoView)
        infoView.anchor(top: titleLabel.bottomAnchor, left: mapView.leftAnchor, right: mapView.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingRight: 12, height: 202)
        infoView.isHidden = true
        
        infoView.addSubview(stackInfo)
        stackInfo.anchor(top: infoView.topAnchor, left: infoView.leftAnchor, bottom: infoView.bottomAnchor, right: infoView.rightAnchor, paddingTop: 6, paddingLeft: 10, paddingBottom: 6, paddingRight: 10)
        
        //bottom view
        view.addSubview(bottomView)
        bottomView.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, height: 50)
        bottomView.delegate = self
        
        view.addSubview(bottomCover)
        bottomCover.anchor(top: bottomView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        //openMapBtn
        mapView.addSubview(openMapButton)
        openMapButton.anchor(bottom: mapView.bottomAnchor, paddingBottom: 12, width: 120, height: 40)
        openMapButton.centerX(inView: mapView)
    }
    
    private func configureMapView() {
        view.addSubview(mapView)
        mapView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: bottomView.topAnchor, right: view.rightAnchor)
        mapView.overrideUserInterfaceStyle = .light
        
        mapView.showsUserLocation = true //show a blue dot indicating current location
        mapView.userTrackingMode = .follow //dot will move if current location moves
        mapView.delegate = self //to enable all func in the extension "MKMapViewDelegate"
        
    }
    


//MARK: - Actions
    
    private func attributedStatText(label: String, value: String) -> NSAttributedString {
        //the "\n" means take another line. the good measure is fontSize = 22 and 16
        let attributedText = NSMutableAttributedString(string: "\(label)", attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .semibold), .foregroundColor: UIColor.green])
        attributedText.append(NSAttributedString(string: value, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.green]))
        
        return attributedText
    }
    
    private func tapImage() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapping))
        imageAnno.addGestureRecognizer(tap)
    }
    
    @objc func tapping() {
        guard let pictureInfo = photoLocationInfo else { return }
        let vc = ImageViewController(imageInfo: pictureInfo)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    private func fetchPhotoData() {
        FetchingStuff.fetchPhotoInfo(email: currentEmail, timeKey: timePhoto) { pictureInfo in
            self.photoLocationInfo = pictureInfo //fill in the data
            self.constructLocation()
            self.tapImage()
            self.showLoadingView(false, message: "Loading..")
        }
    }
    
    @objc func showInfo() {
        infoView.isHidden = !infoView.isHidden
    }
    
    private func configureInfo() {
        guard let lati = photoLocationInfo?.latitude else { return }
        guard let longi = photoLocationInfo?.longitude else { return }
        
        guard let stName = photoLocationInfo?.streetName else { return }
        guard let sta = photoLocationInfo?.state else { return }
        guard let city = photoLocationInfo?.city else { return }
        guard let strNo = photoLocationInfo?.streetNo else { return }
        guard let zip = photoLocationInfo?.zipcode else { return }
        guard let cty = photoLocationInfo?.county else { return }
        guard let ctry = photoLocationInfo?.country else { return }
        guard let timeTaken = photoLocationInfo?.timestamp else { return }
        guard let place = photoLocationInfo?.namePlace else { return }
        
        titleLabel.text = "\(city), \(sta)"
        altitudeInMeter()
        distanceInMile(lat: lati, long: longi)
        addressLabel.attributedText = attributedStatText(label: "Address: ", value: "\(strNo) \(stName), \(place)")
        stateLabel.attributedText = attributedStatText(label: "State: ", value: "\(city), \(zip), \(sta)")
        countyLabel.attributedText = attributedStatText(label: "County: ", value: "\(cty)")
        countryLabel.attributedText = attributedStatText(label: "Country: ", value: "\(ctry)")
        timeLabel.attributedText = attributedStatText(label: "Time: ", value: "\(timeTaken)")
    }
    
    @objc func openMapButtonTapped() {
        guard let lat = photoLocationInfo?.latitude else { return }
        guard let long = photoLocationInfo?.longitude else { return }
        guard let city = photoLocationInfo?.city else { return }
        
        openMap(lati: lat, longi: long, nameMap: city)
    }
    
    
    
//MARK: - Construc Map
    
    private func constructLocation() {
        print("DEBUG: add here anno")
        guard let timeTaken = photoLocationInfo?.timestamp else { return }
        guard let lati = photoLocationInfo?.latitude else { return }
        guard let longi = photoLocationInfo?.longitude else { return }
        
        //let's add an annotation to savedLocation
        let locationAnno = CLLocationCoordinate2D(latitude: lati, longitude: longi)
        let annoPhoto = PictureAnnotation(time: timeTaken, coorPicture: locationAnno)
        annoPhoto.coordinate = locationAnno
        mapView.addAnnotation(annoPhoto)
        mapView.selectAnnotation(annoPhoto, animated: true) //make anno big
//        didAddPhotoAnno = true
        
        //re-center the location for user to see it clearly
        zoomInAnnotation()
        
        //let's generate a polyline to the Location
        generatePolyline(toCoor: locationAnno)
    }
    
    //remember to add the extension "MKMapViewDelegate" below
    func generatePolyline(toCoor: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: toCoor)
        let mapSavedPlace = MKMapItem(placemark: placemark)

        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = mapSavedPlace
        request.transportType = .automobile

        let directionResquest = MKDirections(request: request)
        directionResquest.calculate { (res, error) in
            guard let response = res else { return }
            self.route = response.routes[0] //there are many routes lead to a destination, we just take the first route
            print("DEBUG-MapPhotoVC: we have \(response.routes.count) routes")
            guard let polyline = self.route?.polyline else {
                print("DEBUG-MapPhotoVC: no polyline")
                return
            }
            self.mapView.addOverlay(polyline) //let's add the polyline
        }
    }
    
    @objc func zoomInAnnotation() {
        guard let lat = photoLocationInfo?.latitude else { return }
        guard let long = photoLocationInfo?.longitude else { return }
        
        let locationAnno = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let savedPlace = locationAnno
        let region = MKCoordinateRegion(center: savedPlace, latitudinalMeters: 2000, longitudinalMeters: 2000) //we got 2000 meters around the current location
        mapView.setRegion(region, animated: true)
    }
    
    @objc func zoomOutAnnotation() {
        //let's show all annotations on map, including the current location
        let twoAnnotation = mapView.annotations
        mapView.showAnnotations(twoAnnotation, animated: true)
        mapView.zoomToFit(annotations: twoAnnotation)
    }
    
    private func distanceInMile(lat: CLLocationDegrees, long: CLLocationDegrees) {
        guard let currentLoca = locationManager.location else { return }
        let savedLocation = CLLocation(latitude: lat, longitude: long)
        
        let distanceInMeters = currentLoca.distance(from: savedLocation)
        print("DEBUG-MapPhotoVC: distance is \(distanceInMeters) meters")
        
        let distanceMile = distanceInMeters / 1609
        let d = String(format: "%.2f", distanceMile) //round to 1 decimals

        self.distanceLabel.attributedText = attributedStatText(label: "Distance: ", value: "\(d) mi")
    }
    
    func altitudeInMeter() {
        guard let alt = photoLocationInfo?.altitude else { return }
        let a = String(format: "%.2f", alt)
        altitudeLabel.attributedText = attributedStatText(label: "Altitude: ", value: "\(a)m")
    }
    
}


//MARK: - MapViewDelegate
//remember to write "MapView.delegate = self" in viewDidLoad
extension MapPhotoViewController: MKMapViewDelegate {
    
    //let's modify the polyline
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .black
            lineRenderer.lineWidth = 3
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
    
    //let's configure the picture anno
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotationPhoto = annotation as? PictureAnnotation {
            let vw = MKAnnotationView(annotation: annotationPhoto, reuseIdentifier: annoID)
            vw.backgroundColor = .clear
            vw.setDimensions(height: 130, width: 100)
            
            vw.addSubview(imageAnno)
            imageAnno.anchor(top: vw.topAnchor, left: vw.leftAnchor, bottom: vw.bottomAnchor, right: vw.rightAnchor)
            
            return vw
        }
        return nil
    }
    
}

//MARK: - Privacy Location
//remember to modify the info.plist (go to Notes to see details) before writing these codes, otherwise it crashes
extension MapPhotoViewController: CLLocationManagerDelegate {
    
    //let do some alerts location
    func alertLocationNeeded () {
        
        let alert = UIAlertController (title: "Location needed", message: "Please allow GoChat to access your location in Setting", preferredStyle: .alert)
        let action1 = UIAlertAction (title: "Cancel", style: .cancel, handler: nil)
        let action2 = UIAlertAction (title: "Setting", style: .default) { (action) in
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!) //open the app setting
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        present (alert, animated: true, completion: nil)
    }
    
    //this func will check the location status of the app and enable us to obtain the coordinates of the user.
    //remember to call it in ViewDidLoad
    func checkLocationPermission() {
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        
        //this case is the default case
        case .notDetermined:
            print("DEBUG-MapPhotoVC: location notDetermined")
            //locationManager?.requestWhenInUseAuthorization() //ask user to access location, when user allows to access, we hit case "whenInUse"
            locationManager.requestAlwaysAuthorization()
        case .restricted, .denied:
            print("DEBUG-MapPhotoVC: location restricted/denied")
            alertLocationNeeded()
            break
        case .authorizedAlways: //so this app only works in case of "authorizedAlways", in real app, we can modify it
            print("DEBUG-MapPhotoVC: location always")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest //get current user's location and zoom into it
        case .authorizedWhenInUse:
            print("DEBUG-MapPhotoVC: location whenInUse")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest //get current user's location and zoom into it
        @unknown default:
            print("DEBUG-MapPhotoVC: location default")
            break
        }
    }
    
    //let's evaluate the case from HomeVC, it activates after we done picking a case in func "enableLocationService"
    //this one need inheritance from "CLLocationManagerDelegate"
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            print("DEBUG-MapPhotoVC: current status is whenInUse")
        } else if status == .authorizedAlways {
            print("DEBUG-MapPhotoVC: current status is always")
        } else if status == .denied {
            print("DEBUG-MapPhotoVC: current status is denied")
            alertLocationNeeded()
            
        }
    }
    
    
}

//MARK: - Protocol from MapBottomView
//remember to write ".delegate = self" in viewDidLoad
extension MapPhotoViewController: MapBottomViewDelegate {
    func zoomIn() {
        zoomInAnnotation()
    }
    
    func zoomOut() {
        zoomOutAnnotation()
    }
    
    func sendTo() {
        
    }
    
    func shareTo() {
        guard let latitude = photoLocationInfo?.latitude else { return }
        guard let longitude = photoLocationInfo?.longitude else { return }
        
        let urlString = MapExtension.sharingLocationURL(lat: latitude, long: longitude)
        
        guard let LocationUrl = URL(string: urlString) else { return }
        
        let shareText = "Share Location"
        
        let vc = UIActivityViewController(activityItems: [shareText, LocationUrl], applicationActivities: nil)
        present(vc, animated: true, completion: nil)
    }
    
    func dismissMapPhoto() {
        if fromSearch {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    
}
