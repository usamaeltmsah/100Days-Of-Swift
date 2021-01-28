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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                print(3)
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }

    
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        // Did we get authorized by the user?
//        if manager.authorizationStatus == .authorizedAlways {
//            print("Alway")
//            startScanning()
//            // Is our device able to monitor iBeacons?
//            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
//                print("122")
//                // Is ranging available? (Ranging is the ability to tell roughly how far something else is away from our device.)
//                if CLLocationManager.isRangingAvailable() {
//                    startScanning()
//                }
//            }
//        }
//    }
    
//    func startScanning() {
//        // "5A4BCFCE ...": Know text(HEXADECIMAL) Beacon assigned by Apple
//        let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
////        let beaconRegion = CLBeaconRegion(uuid: uuid, major: 123, minor: 456, identifier: "MyBeacon")
//        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "MyBeacon")
//
//        locationManager?.startMonitoring(for: beaconRegion)
////        locationManager?.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
//        locationManager?.startRangingBeacons(in: beaconRegion)
//        print(1)
//    }
//
//    func update(distance: CLProximity) {
//        UIView.animate(withDuration: 1) {
//            switch distance {
//            case .immediate:
//                self.view.backgroundColor = .red
//                self.distanceReading.text = "RIGHT HERE!"
//            case .near:
//                self.view.backgroundColor = .orange
//                self.distanceReading.text = "NEAR"
//            case .far:
//                self.view.backgroundColor = .blue
//                self.distanceReading.text = "FAR"
//            default:
//                self.view.backgroundColor = .gray
//                self.distanceReading.text = "UNKNOWN"
//            }
//        }
//    }
    
    func startScanning() {
        let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "MyBeacon")

        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(in: beaconRegion)
    }
    
    func update(distance: CLProximity) {
        UIView.animate(withDuration: 0.8) {
            switch distance {
            case .far:
                self.view.backgroundColor = UIColor.blue
                self.distanceReading.text = "FAR"

            case .near:
                self.view.backgroundColor = UIColor.orange
                self.distanceReading.text = "NEAR"

            case .immediate:
                self.view.backgroundColor = UIColor.red
                self.distanceReading.text = "RIGHT HERE"

            default:
                self.view.backgroundColor = UIColor.gray
                self.distanceReading.text = "UNKNOWN"
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacon = beacons.first {
            print(1)
            update(distance: beacon.proximity)
        } else {
            print(2)
            update(distance: .unknown)
        }
    }
    
//    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
//        if let beacon = beacons.first {
//            print("234")
//            update(distance: beacon.proximity)
//        } else {
//            print("ervfr")
//            update(distance: .unknown)
//        }
//    }


}

