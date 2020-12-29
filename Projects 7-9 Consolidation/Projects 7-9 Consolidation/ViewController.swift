//
//  ViewController.swift
//  Projects 7-9 Consolidation
//
//  Created by Usama Fouad on 28/12/2020.
//

import UIKit

class ViewController: UIViewController {
    var allWords = [String]()
    var slectedWord: String!
    
    var currentAnswer: UITextField!
    var scoreLabel: UILabel!
    var letterButtons = [UIButton]()
    var trialsLabel: UILabel!
    let buttonsView = UIView()
    
    var activatedButtons = [UIButton]()
    var solutions = [String]()
    
    let englishLetters = Array("abcdefghijklmnopqrstuvwxyz")
    
    var trials = 7 {
        didSet {
            trialsLabel.text = "Trials: \(trials)"
        }
    }
    var numberOfCorrectAnswers = 0
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
