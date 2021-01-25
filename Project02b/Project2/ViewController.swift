//
//  ViewController.swift
//  Project2
//
//  Created by Usama Fouad on 12/12/20.
//

import UIKit

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    @IBOutlet var highScoreLabel: UILabel!
    
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    var count = 0
    
    var messages: [String] = []
    
    var highScore = 0 {
        didSet {
            highScoreLabel.text = "High Score: \(highScore)"
        }
    }
    
    var countryLabel: UILabel!
    var scoreLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Show Score", style: .plain, target: self, action: #selector(showScore))
        
        let defaults = UserDefaults.standard
        
        if let savedHighScore = defaults.object(forKey: "highScore") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                highScore = try jsonDecoder.decode(Int.self, from: savedHighScore)
            } catch {
                print("Failed to load highScore.")
            }
        }
        registerLocal()
        scheduleLocal()
        startGame()
    }
    
    func startGame() {
        addFlagsBorders()
        askQuestion()
    }

    func addFlagsBorders() {
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
    }

    func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        count += 1
        addViewsToNavBar()
    }
    
    func addViewsToNavBar() {
        let title = countries[correctAnswer].uppercased()
        
        let navBar = navigationController?.navigationBar
        let labelWidth = (navBar!.bounds.width) - 50

        countryLabel = UILabel(frame: CGRect(x:(navBar!.bounds.width/2) - (labelWidth/2), y:0, width:labelWidth, height:navBar!.bounds.height))
//        scoreLabel = UILabel(frame: CGRect(x:(navBar!.bounds.width) - (labelWidth/2), y:0, width:labelWidth, height:navBar!.bounds.height))
        countryLabel.font = UIFont.boldSystemFont(ofSize: 23.0)
//        scoreLabel.font = UIFont.systemFont(ofSize: 20.0)
        countryLabel.text = title
//        scoreLabel.text = "Score: \(score)"
        navBar!.addSubview(countryLabel)
//        navBar!.addSubview(scoreLabel)
    }
    
    func resetViewsOfNavBar() {
        if let clabel = countryLabel{
            clabel.removeFromSuperview()
        }
        if let sclabel = scoreLabel{
            sclabel.removeFromSuperview()
        }
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String
        
        UIView.animate(withDuration: 1.5, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }) { finished in
            sender.transform = .identity
        }
        
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
        } else {
            title = "Wrong! That’s the flag of \(countries[sender.tag])"
        }
        
        if count == 10 {
            finalAlert()
            resetViewsOfNavBar()
        }
        
        let ac = UIAlertController(title: title, message: "Your score is \(score)", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
        resetViewsOfNavBar()
        present(ac, animated: true)
    }
    
    func finalAlert() {
        if score > highScore {
            highScore = score
            saveHighScore()
            alertNewScore()
        } else {
            let ac = UIAlertController(title: title, message: "Your final score is \(score)/10", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "Play Again!", style: .default, handler: restartGame))
            present(ac, animated: true)
        }
    }
    
    func alertNewScore() {
        let ac = UIAlertController(title: "New High Score", message: "Congrats, You get a new high score is \(highScore)/10", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Play Again!", style: .default, handler: restartGame))
        present(ac, animated: true)
        
    }
    
    func restartGame(action: UIAlertAction) {
        count = 0
        score = 0
        
        startGame()
    }
    
    @objc func showScore() {
        let ac = UIAlertController(title: title, message: "Your current score is \(score)/10", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func saveHighScore() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(highScore) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "highScore")
        } else {
            print("Failed to save High Score")
        }
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
        content.title = "Let's play!"
        content.body = "It's time to play the flags game."
        
        // categoryIdentifier: attach custom actions.
        content.categoryIdentifier = "alarm"
        // userInfo dictionary: To attach custom data to the notification, e.g. an internal ID, use the.
        content.userInfo = ["customData": "fizzbuzz"]
        // MARK: UNNotificationSound object: User if you want to specify a sound.
        content.sound = .default
        
        // Repeat the notification every morning at 10:30am
        var dateComponents = DateComponents()
        dateComponents.weekday = 7
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // MARK: center.removeAllPendingNotificationRequests(): Used to cancel pending notifications – i.e., notifications you have scheduled that have yet to be delivered because their trigger hasn’t been met.
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        
        // Setting the delegate property of the user notification center to be self, meaning that any alert-based messages that get sent will be routed to our view controller to be handled.
        center.delegate = self
        
        // Options, describe any special options that relate to the action. You can choose from .authenticationRequired, .destructive, and .foreground.
        let remindLater = UNNotificationAction(identifier: "later", title: "Remind me later", options: .destructive)
                
        // Once you have as many actions as you want, you group them together into a single UNNotificationCategory and give it the same identifier you used with a notification.
        // intentIdentifiers: Used to connect your notifications to intents, if you have created any.
        let category = UNNotificationCategory(identifier: "alarm", actions: [remindLater], intentIdentifiers: [])

        center.setNotificationCategories([category])
        
        center.removeAllPendingNotificationRequests()
    }
}

