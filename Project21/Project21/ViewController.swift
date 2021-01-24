//
//  ViewController.swift
//  Project21
//
//  Created by Usama Fouad on 24/01/2021.
//

import UserNotifications
import UIKit

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
    }
    
    @objc func registerLocal() {
        registerCategories()
        
        // Get access to current version user notification center, which one lets us post messages to the home screen.
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Yay!")
            } else {
                print("D'oh!")
            }
        }
    }
    
    @objc func scheduleLocal() {
        // This method will configure all the data needed to schedule a notification, which is three things:-
        // content (what to show), a trigger (when to show it), and a request (the combination of content and trigger.)
        
        let center = UNUserNotificationCenter.current()
        
        // UNMutableNotificationContent: What to show
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese."
        
        // categoryIdentifier: attach custom actions.
        content.categoryIdentifier = "alarm"
        // userInfo dictionary: To attach custom data to the notification, e.g. an internal ID, use the.
        content.userInfo = ["customData": "fizzbuzz"]
        // MARK: UNNotificationSound object: User if you want to specify a sound.
        content.sound = .default
        
        // Repeat the notification every morning at 10:30am
//        var dateComponents = DateComponents()
//        dateComponents.hour = 10
//        dateComponents.minute = 30
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // MARK: center.removeAllPendingNotificationRequests(): Used to cancel pending notifications – i.e., notifications you have scheduled that have yet to be delivered because their trigger hasn’t been met.
        // Wait 5 seconds then show the notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let show = UNNotificationAction(identifier: "show", title: "Tell me more ...", options: .foreground)
        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [])

        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // The user swiped to unlock
                print("Default identifer")
            case "show":
                print("Show more information...")
            default:
                break
            }
        }
        
        completionHandler()
    }


}

