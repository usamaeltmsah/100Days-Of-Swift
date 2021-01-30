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
    @IBOutlet var beaconIdLabel: UILabel!
    // Core Location class that lets us configure how we want to be notified about location, and will also deliver location updates to us.
    var locationManager: CLLocationManager?
    
    var alertShown = false
    
    var circle: CAShapeLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        // requestAlwaysAuthorization(): if you have already been granted location permission then things will Just Work; if you haven't, iOS will request it now.
        // requestWhenInUseAuthorization(): When in use location permission.
        locationManager?.requestAlwaysAuthorization()
        
        view.backgroundColor = .gray
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 205, y: 370), radius: 128, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
            
        circle = CAShapeLayer()
        circle.path = circlePath.cgPath
            
        circle.fillColor = UIColor.clear.cgColor
        circle.strokeColor = UIColor.red.cgColor
        circle.lineWidth = 10.0
            
        view.layer.addSublayer(circle)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
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
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "MyBeacon - 5A4BCFCE")
        
        let uuid2 = UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!
        let beaconRegion2 = CLBeaconRegion(proximityUUID: uuid2, major: 1, minor: 2, identifier: "MyBeacon - E2C56DB5")

        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(in: beaconRegion)
        
        locationManager?.startMonitoring(for: beaconRegion2)
        locationManager?.startRangingBeacons(in: beaconRegion2)
        
        let uuid3 = UUID(uuidString: "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6")!
        let beaconRegion3 = CLBeaconRegion(proximityUUID: uuid3, major: 1, minor: 2, identifier: "MyBeacon - 2F234454")

        locationManager?.startMonitoring(for: beaconRegion3)
        locationManager?.startRangingBeacons(in: beaconRegion3)
    }
    
    func update(distance: CLProximity) {
        UIView.animate(withDuration: 0.8) {
            switch distance {
            case .far:
                self.circle.scaleAndChangeColor(scaledby: 0.25, color: .blue)
                self.view.backgroundColor = UIColor.blue
                self.distanceReading.text = "FAR"

            case .near:
                self.circle.scaleAndChangeColor(scaledby: 0.5, color: .blue)
                self.view.backgroundColor = UIColor.orange
                self.distanceReading.text = "NEAR"

            case .immediate:
                self.circle.scaleAndChangeColor(scaledby: 1.0, color: .blue)
                self.view.backgroundColor = UIColor.red
                self.distanceReading.text = "RIGHT HERE"

            default:
                self.circle.scaleAndChangeColor(scaledby: 0.001, color: .blue)
                self.view.backgroundColor = UIColor.gray
                self.distanceReading.text = "UNKNOWN"
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacon = beacons.first {
            if !alertShown {
                showAlert()
            }
            beaconIdLabel.text = region.identifier
            alertShown = true
            update(distance: beacon.proximity)
        } else {
            beaconIdLabel.text = ""
            alertShown = false
            update(distance: .unknown)
        }
    }
    
    func showAlert() {
        let ac = UIAlertController(title: "Beacon detected!", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(ac, animated: true)
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

extension CAShapeLayer {
    // Use animation to scale a circle and change it's color.
    func scaleAndChangeColor(scaledby value: CGFloat, color: UIColor) {
            self.strokeColor = color.cgColor
            self.transform = CATransform3DMakeScale(value, value, 1.0)
    }
}
