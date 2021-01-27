//
//  ViewController.swift
//  Project22
//
//  Created by Usama Fouad on 27/01/2021.
//

import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet var distanceReading: UILabel!
    // Core Location class that lets us configure how we want to be notified about location, and will also deliver location updates to us.
    var locationManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        // requestAlwaysAuthorization(): if you have already been granted location permission then things will Just Work; if you haven't, iOS will request it now.
        // requestWhenInUseAuthorization(): When in use location permission.
        locationManager?.requestAlwaysAuthorization()
        
        view.backgroundColor = .gray
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Did we get authorized by the user?
        if manager.authorizationStatus == .authorizedAlways {
            // Is our device able to monitor iBeacons?
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                // Is ranging available? (Ranging is the ability to tell roughly how far something else is away from our device.)
                if CLLocationManager.isRangingAvailable() {
                    // Do stuff
                }
            }
        }
    }


}

