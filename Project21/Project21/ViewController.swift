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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(schedule))
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
    
    @objc func schedule() {
        scheduleLocal()
        schedualAlert()
    }
    
    func scheduleLocal() {
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
        // 86400 per day
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        
        // Setting the delegate property of the user notification center to be self, meaning that any alert-based messages that get sent will be routed to our view controller to be handled.
        center.delegate = self
        
        // Options, describe any special options that relate to the action. You can choose from .authenticationRequired, .destructive, and .foreground.
        let show = UNNotificationAction(identifier: "show", title: "Tell me more ...", options: .foreground)
        
        let remindLater = UNNotificationAction(identifier: "later", title: "Remind me later", options: .destructive)
                
        // Once you have as many actions as you want, you group them together into a single UNNotificationCategory and give it the same identifier you used with a notification.
        // intentIdentifiers: Used to connect your notifications to intents, if you have created any.
        let category = UNNotificationCategory(identifier: "alarm", actions: [show, remindLater], intentIdentifiers: [])

        center.setNotificationCategories([category])
    }
    
    // didReceive method: is triggered on our view controller because we’re the center’s delegate, so it’s down to us to decide how to handle the notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // pull out the buried userInfo dictionary
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // The user swiped to unlock
                defualtAlert()
            case "show":
                // the user tapped our "show more info…" button
                showMoreInfoAlert()
            case "later":
                scheduleLocal()
            default:
                break
            }
        }
        
        // you must call the completion handler when you're done
        completionHandler()
    }
    
    func showMoreInfoAlert() {
        let ac = UIAlertController(title: "More information", message: "This is a result for clicking on show more inforamation button.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func defualtAlert() {
        let ac = UIAlertController(title: "Default", message: "This is a result for clicking on the default notification", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func schedualAlert() {
        let ac = UIAlertController(title: "Schedualed succesfully!", message: "I will remind you in 24 hrs :)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }


}

