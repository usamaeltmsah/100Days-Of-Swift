//
//  ViewController.swift
//  Project2
//
//  Created by Usama Fouad on 12/12/20.
//

import UIKit

class ViewController: UIViewController {
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
}

