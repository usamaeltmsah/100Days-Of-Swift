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
    
    override func loadView() {
        loadWords()
        
        loadUI()
    }
    
    func loadWords() {
        if let startWordsURL = Bundle.main.url(forResource: "words", withExtension: "txt") {
            if let words = try? String(contentsOf: startWordsURL) {
                allWords = words.components(separatedBy: "\n")
            }
        }
    }
    
    func loadUI() {
        view = UIView()
        view.backgroundColor = .white
        
        scoreLabel = UILabel()
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: 0"
        
        trialsLabel = UILabel()
        trialsLabel.textAlignment = .right
        trialsLabel.text = "Trials: \(trials)"
        
        currentAnswer = UITextField()
        currentAnswer.textAlignment = .center
        currentAnswer.font = UIFont.systemFont(ofSize: 20)
        currentAnswer.isUserInteractionEnabled = false
        
        addSubViewsToView()
        
        addButtonsToButtonsView()
                
        addConstraintsToViews()
    }
    
    func addSubViewsToView() {
        let views = [scoreLabel, trialsLabel, currentAnswer, buttonsView]
        
        for currentView in views {
            currentView?.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(currentView!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
