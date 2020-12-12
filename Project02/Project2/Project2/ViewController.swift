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
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    var count = 0
    
    var countryLabel: UILabel!
    var scoreLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
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
        let labelWidth = (navBar!.bounds.width) - 110

        countryLabel = UILabel(frame: CGRect(x:(navBar!.bounds.width/2) - (labelWidth/2), y:0, width:labelWidth, height:navBar!.bounds.height))
        scoreLabel = UILabel(frame: CGRect(x:(navBar!.bounds.width) - (labelWidth/2), y:0, width:labelWidth, height:navBar!.bounds.height))
        countryLabel.font = UIFont.boldSystemFont(ofSize: 23.0)
        scoreLabel.font = UIFont.systemFont(ofSize: 20.0)
        countryLabel.text = title
        scoreLabel.text = "Score: \(score)"
        navBar!.addSubview(countryLabel)
        navBar!.addSubview(scoreLabel)
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
        let ac = UIAlertController(title: title, message: "Your final score is \(score)/10", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Restart", style: .default, handler: restartGame))
        present(ac, animated: true)
    }
    
    func restartGame(action: UIAlertAction) {
        count = 0
        score = 0
        
        startGame()
    }
}

