//
//  MapViewController.swift
//  GoChat
//
//  Created by Long Nguyen on 8/10/21.
//

import UIKit
import Firebase
import MapKit
import SDWebImage

private let annoPictID = "annoPictID"

protocol MapViewControllerDelegate: AnyObject {
    func showBottomMap()
    func showBottomBar()
}

class MapViewController: UIViewController {
    
    weak var delegate: MapViewControllerDelegate?

    private let userEmail = Auth.auth().currentUser?.email ?? "no email"
    private var bigImagesArray = [Picture]()
    private var reloadMap: NSObjectProtocol?

    private var locationManager: CLLocationManager!
    private var route: MKRoute? //use this to generate polyline
    private var selectedAnnoInfo: SelectedAnno?
    private var arrayTwoAnno = [MKPointAnnotation]()
    private var hasPolylines = false
    
//MARK: - Components
    
    private let mapView = MKMapView()
    
    private let bottomMapView = BottomMapActionView()
    
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
    
    private let rightSmallView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        return vw
    }()
    
//MARK: - View Scenes
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        checkLocationPermission()
        configureMapView()
        fetchAllPhotos()
        configureUI()
        protocolVC()
        
    }
    
    private func configureUI() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(configure))
//        view.addGestureRecognizer(tap)
        
        view.addSubview(rightSmallView)
        rightSmallView.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, width: 20)
        
        view.addSubview(bottomMapView)
        bottomMapView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, height: 180) //btn height = 40
        bottomMapView.delegate = self
        bottomMapView.isHidden = true
    }
    
    
    private func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.bounds
        mapView.overrideUserInterfaceStyle = .dark
        
        mapView.showsUserLocation = true //show a blue dot indicating current location
        mapView.userTrackingMode = .follow //dot will move if current location moves
        mapView.delegate = self //to enable all func in the extension "MKMapViewDelegate"
        
    }
    
//MARK: - Protocol
    
    func protocolVC() {
        //protocol from SettingVC
        reloadMap = NotificationCenter.default.addObserver(forName: .refreshMap, object: nil, queue: .main) { [weak self] _ in
            
            print("DEBUG-MapVC: protocol from CameraVC, reloading map")
            guard let strongSelf = self else { return }
            strongSelf.refreshMapAfterTakingPhoto()
        }
        
    }
    
    
    //this func is exclusively unique for protocol
    deinit {
        if let observer1 = reloadMap {
            NotificationCenter.default.removeObserver(observer1)
        }
    }
    
//MARK: - Actions
    
    private func fetchAllPhotos() {
        showLoadingView(true, message: "Loading Images")
        FetchingStuff.fetchPhotos(email: userEmail) { photosArray in
            self.bigImagesArray = photosArray
            print("DEBUG-MapVC: we got \(self.bigImagesArray.count) iamges")
            self.constructAllPhotos()
            self.showLoadingView(false, message: "Loading Images")
        }
    }
    
    private func refreshMapAfterTakingPhoto() {
        removeAllPolyline()
        centerCurrentLocation()
        hasPolylines = false
        selectedAnnoInfo = nil
        
        fetchAllPhotos()
    }
    
    private func constructAllPhotos() {
        for imgInfo in bigImagesArray {
            self.addAnAnno(lat: imgInfo.latitude, long: imgInfo.longitude, timestamp: imgInfo.timestamp)
        }
    }
    
    private func addAnAnno(lat: CLLocationDegrees, long: CLLocationDegrees, timestamp: String) {
        let coor = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let anno = MKPointAnnotation()
        anno.coordinate = coor
        mapView.addAnnotation(anno)
        //mapView.selectAnnotation(anno, animated: true) //make anno big
    }
    
    @objc func zoomInAnnotation(lat: CLLocationDegrees, long: CLLocationDegrees) {
        let locationAnno = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let savedPlace = locationAnno
        let region = MKCoordinateRegion(center: savedPlace, latitudinalMeters: 2000, longitudinalMeters: 2000) //we got 2000 meters around the current location
        mapView.setRegion(region, animated: true)
    }
    
    @objc func zoomOutAnnotation() {
        mapView.showAnnotations(arrayTwoAnno, animated: true)
        mapView.zoomToFit(annotations: arrayTwoAnno)
    }
    
    @objc func centerCurrentLocation() {
        guard let coordinate = locationManager?.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000) //we got 1000 meters around the current location
        mapView.setRegion(region, animated: true)
    }
    
    //remember to add the extension "MKMapViewDelegate" below
    private func generatePolyline(toCoor: CLLocationCoordinate2D) {
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
    
    
    private func removeAllPolyline() {
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
    
    private func distanceInMile(lat: CLLocationDegrees, long: CLLocationDegrees) {
        guard let currentLoca = locationManager.location else { return }
        let savedLocation = CLLocation(latitude: lat, longitude: long)
        
        let distanceInMeters = currentLoca.distance(from: savedLocation)
        print("DEBUG-MapPhotoVC: distance is \(distanceInMeters) meters")
        
        let distanceMile = distanceInMeters / 1609
        let d = String(format: "%.2f", distanceMile) //round to 1 decimals
        
//        self.distanceLabel.attributedText = attributedStatText(label: "Distance: ", value: "\(d) mi")
    }
    
//MARK: - Bottom action
    
    private func configureBottomAction() {
        delegate?.showBottomMap()
        bottomMapView.isHidden = false
        UIView.animate(withDuration: 0.4) {
            self.bottomMapView.alpha = 1
        }
        
    }
    
   

}

//MARK: - MapViewDelegate
//remember to write "MapView.delegate = self" in viewDidLoad
extension MapViewController: MKMapViewDelegate {
    
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
    
    //this dictates what happen when we tap on an annotation OR add a new one
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let toCoor = view.annotation?.coordinate else { return }
        guard let coorCurrent = locationManager.location?.coordinate else { return }
        guard let titleDestination = view.annotation?.title else { return }
        guard let altDestination = view.annotation?.subtitle else { return }
        let distanceToD = distanceInMile(lat: toCoor.latitude, long: toCoor.longitude)
        
        let anno1 = MKPointAnnotation()
        anno1.coordinate = toCoor
        let anno2 = MKPointAnnotation()
        anno2.coordinate = coorCurrent
        let array = [anno1, anno2] //has currentLocation and destination to zoom
        
        //let's check if user pick the same OR different anno
        let pickedAnno = SelectedAnno(lat: toCoor.latitude, long: toCoor.longitude)
        
        if selectedAnnoInfo == pickedAnno {
            print("DEBUG-MapVC: we already have a polyline for this")
        } else {
            //this case means that user has tapped a new anno after tapping a previous one
            if hasPolylines {
                //remove the previous polyline
                print("DEBUG-MapVC: removing a polyline..")
                guard let polyline = self.route?.polyline else { return }
                self.mapView.removeOverlay(polyline)
                
                //set some info for the new anno
                arrayTwoAnno = array
                selectedAnnoInfo = SelectedAnno(lat: toCoor.latitude, long: toCoor.longitude) //for checking if user has tapped on this anno
                
                //let's present a polyline, zoom to it, and show bottomAction
                generatePolyline(toCoor: toCoor)
                zoomInAnnotation(lat: toCoor.latitude, long: toCoor.longitude)
                configureBottomAction()
                
                //assign the info so that we can indicate duplicating taps
//                latShare = toCoor.latitude
//                longShare = toCoor.longitude
//                titleShare = titleDestination
                
            } else { //user has initially tapped on an anno
                
                //let's pass info to global-class var
                arrayTwoAnno = array
                selectedAnnoInfo = SelectedAnno(lat: toCoor.latitude, long: toCoor.longitude)
                
                //let's do some cool stuff
                generatePolyline(toCoor: toCoor)
                zoomInAnnotation(lat: toCoor.latitude, long: toCoor.longitude)
                configureBottomAction()
                
                //assign the info so that we can indicate duplicating taps
//                latShare = toCoor.latitude
//                longShare = toCoor.longitude
//                titleShare = titleDestination
                hasPolylines = true
            }
        }
        
    }//end of func
    
    
}

//MARK: - Privacy Location
//remember to modify the info.plist (go to Notes to see details) before writing these codes, otherwise it crashes
extension MapViewController: CLLocationManagerDelegate {
    
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

//MARK: - Protocol BottomMapActionView
extension MapViewController: BottomMapActionViewDelegate {
    func sendTo() {
        
    }
    
    func zoomIn() {
        zoomInAnnotation(lat: selectedAnnoInfo?.lat ?? 0, long: selectedAnnoInfo?.long ?? 0)
    }
    
    func zoomOut() {
        zoomOutAnnotation()
    }
    
    func dismiss() {
        removeAllPolyline()
        centerCurrentLocation()
        hasPolylines = false
        selectedAnnoInfo = nil
        
        UIView.animate(withDuration: 0.2) {
            self.bottomMapView.alpha = 0
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.delegate?.showBottomBar()
            }
        }
        
    }
    
    func share() {
        
    }
    
    
}
