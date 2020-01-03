//
//  EatMoreVegetableLocationViewController.swift
//  EatMoreVegetable
//
//  Created by Rapsodo Mobile 6 on 18.12.2019.
//  Copyright © 2019 Rapsodo Mobile 6. All rights reserved.
//

import UIKit
import MapKit


protocol EatMoreVegetableLocationViewControllerDelegate {
    
    func setLocation(location: String)
    func setLocationCoordinates(coordinates: CLLocationCoordinate2D)
}

enum mapMode {
    
    case pick
    case visit
}

class EatMoreVegetableLocationViewController: UIViewController {
    
    //MARK: Properties
    let regionRadius: CLLocationDistance = 1000
    @IBOutlet weak var mapView: MKMapView!
    var location: String?
    var locationCoordinates: CLLocationCoordinate2D?
    var latitude: Double?
    var longtitude: Double?
    var delegate: EatMoreVegetableLocationViewControllerDelegate?
    var pageMode: mapMode = .pick

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch pageMode {
        // Case for picking a new location
        case .pick:
            mapView.delegate = (self as MKMapViewDelegate)
            let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
            mapView.addGestureRecognizer(longTapGesture)
        
        // Case for visiting the saved location
        case .visit:
            // set initial location
            let initialLocation = CLLocation(latitude: self.latitude!, longitude: self.longtitude!)
            centerMapOnLocation(location: initialLocation)
            let annotationVisit = MKPointAnnotation()
            annotationVisit.coordinate.latitude = self.latitude!
            annotationVisit.coordinate.longitude = self.longtitude!
            annotationVisit.title = self.location
            self.mapView.addAnnotation(annotationVisit)
        }
        
    }
    
    @objc func longTap(sender: UIGestureRecognizer){
        
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            self.locationCoordinates = locationOnMap
            addAnnotation(location: locationOnMap)
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func addAnnotation(location: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        
        // Alert Box
        let alert = UIAlertController(title: "Please type the name of the place. Then, choose the location.", message: "Enter a text", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.text = "A Good Place"
        }

        alert.addAction(UIAlertAction(title: "DONE", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            annotation.title = textField?.text
            self.location = textField?.text
        }))

        self.present(alert, animated: true, completion: nil)
        
        annotation.subtitle = "A Good Place"
        self.mapView.addAnnotation(annotation)
    }

}

//MARK: EatMoreVegetableLocationViewController
extension EatMoreVegetableLocationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }

        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
            pinView!.pinTintColor = UIColor.black
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if nil != view.annotation?.title! {
                self.delegate?.setLocation(location: self.location!)
                self.delegate?.setLocationCoordinates(coordinates: self.locationCoordinates!)
                self.navigationController?.popViewController(animated: true)
            }
        }
      }
    
}
