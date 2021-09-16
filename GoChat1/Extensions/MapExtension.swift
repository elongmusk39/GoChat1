//
//  MapExtension.swift
//  GoChat
//
//  Created by Long Nguyen on 8/14/21.
//

import UIKit
import MapKit

//MARK: - extension MKMapView

extension MKMapView {
    //we zoom the map to fit 2 annotations on the screen
    func zoomToFit(annotations: [MKAnnotation]) {
        var zoomRect = MKMapRect.null
        
        annotations.forEach { anno in
            let annotationPoint = MKMapPoint(anno.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01)
            zoomRect = zoomRect.union(pointRect)
            
        }
        let insets = UIEdgeInsets(top: 100, left: 50, bottom: 170, right: 50)
        setVisibleMapRect(zoomRect, edgePadding: insets, animated: true)
    }
    
    
}

extension UIViewController {
    
    func openMap(lati: CLLocationDegrees?, longi: CLLocationDegrees?, nameMap: String?) {
        print("DEBUG-MapExtension: openMapButton tapped..")
        guard let lat = lati else { return }
        guard let long = longi else { return }
        guard let nameMapAddress = nameMap else { return }
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(lat, long)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = nameMapAddress
        mapItem.openInMaps(launchOptions: options)
    }
    
}

//MARK: - Map Extension

struct MapExtension {
    
    static func sharingLocationURL(lat: Double, long: Double) -> String {
        
        let urlString = "https://maps.apple.com?ll=\(lat),\(long)&q=Location&_ext=EiQpzUnuGHYRQUAx0xl+LFqWXcA5zUnuGHYRQUBB0xl+LFqWXcA%3D&t=m" //this url is contructed from playing with telegram
        
        return urlString
    }
    
}
