//
//  ViewController.swift
//  Project16
//
//  Created by Usama Fouad on 15/01/2021.
//

import MapKit
import UIKit

class ViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mapTypeButton = UIBarButtonItem(title: "Map Type", style: .plain, target: self, action: #selector(changeMapType))
        
        navigationItem.rightBarButtonItem = mapTypeButton
        
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home the 2012 Summer Olympics")
        
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago")
        
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the city of Light")
        
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it")
        
        let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself")
        
        let cairo = Capital(title: "Cairo", coordinate: CLLocationCoordinate2D(latitude: 30.0444, longitude: 31.2357), info: " The third largest, and second-most populous city in Africa.")
        
        let gaza = Capital(title: "Gaza_Strip", coordinate: CLLocationCoordinate2D(latitude: 31.3547, longitude: 34.3088), info: "Capital of Palestine")
        
        mapView.addAnnotations([london, oslo, paris, rome, washington, cairo, gaza])
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Capital else { return nil}
        
        let identifier = "Capital"
        
        var annotaionView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotaionView == nil {
            annotaionView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotaionView?.canShowCallout = true
            
            let btn = UIButton(type: .detailDisclosure)
            annotaionView?.rightCalloutAccessoryView = btn
        } else {
            annotaionView?.annotation = annotation
        }
        
        if let annotaionView = annotaionView as? MKPinAnnotationView {
            annotaionView.pinTintColor = .blue
        }
        
        return annotaionView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard  let capital = view.annotation as? Capital else { return }
        
        let placeName = capital.title
//        let placeInfo = capital.info
        
        let web = storyboard?.instantiateViewController(identifier: "Wikipedia") as! WekepediaWebViewController
        web.title = placeName
        
        self.navigationController?.pushViewController(web, animated: true)
//        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
//        ac.addAction(UIAlertAction(title: "OK", style: .default))
//        
//        present(ac, animated: true)
    }
    
    @objc func changeMapType() {
        let ac = UIAlertController(title: "Choose Map type", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Standard", style: .default, handler: { _ in
            self.mapView.mapType = .standard
        } ))
        
        ac.addAction(UIAlertAction(title: "Satellite", style: .default, handler: { _ in
            self.mapView.mapType = .satellite
        } ))
        
        ac.addAction(UIAlertAction(title: "Satellite Flyover", style: .default, handler: { _ in
            self.mapView.mapType = .satelliteFlyover
        } ))
        
        ac.addAction(UIAlertAction(title: "Hybrid Flyover", style: .default, handler: { _ in
            self.mapView.mapType = .hybridFlyover
        } ))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        
        present(ac, animated: true)
    }


}

