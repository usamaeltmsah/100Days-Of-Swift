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
    
    func addButtonsToButtonsView() {
        let screenSize: CGRect = UIScreen.main.bounds
        // Set some values for the width and height of each button
        let width = screenSize.width / 5
        let height = screenSize.height / 15

        // Create 20 buttons as a 4x5 grid
        for row in 0..<4 {
            for col in 0..<5 {
                // Create a new button and give it a big font size
                let letterButton = UIButton(type: .system)
                letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
                
                styleLetterButton(button: letterButton)

                // Calculate the frame of this button using its column and row
                
                let frame = CGRect(x: CGFloat(col) * width, y: CGFloat(row) * height, width: width, height: height)
                letterButton.frame = frame

                // Add it to the buttons view
                buttonsView.addSubview(letterButton)

                // And also to our letterButtons array
                letterButtons.append(letterButton)
            }
        }
    }
    
    func addConstraintsToViews() {
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            scoreLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5),
            
            trialsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            trialsLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5),
            
            currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentAnswer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            
            buttonsView.widthAnchor.constraint(equalTo: view.widthAnchor),
            buttonsView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor, constant: 20),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
        ])
    }
    
    func styleLetterButton(button: UIButton!) {
        button.tintColor = .black
        button.titleLabel?.font = UIFont.systemFont(ofSize: 36)
        button.layer.borderWidth = 1
        button.alpha = 0.7
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.cornerRadius = 15
        button.backgroundColor = .cyan
    }
    
    @objc func letterTapped(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else { return }
        sender.alpha = 0.1
        sender.isEnabled = false
        if slectedWord.contains(buttonTitle) {
            let indicies = slectedWord.indicesOf(string: buttonTitle)
            activatedButtons.append(sender)
            currentAnswer.text?.replace(at: indicies, with: buttonTitle)
        } else {
            trials -= 1
        }
        checkCurrentAnswer(answer: currentAnswer.text!)
    }
    
    func checkCurrentAnswer(answer: String) {
        if answer == slectedWord {
            congratulationAnswerIsCorrect()
            score += 1
            startGame()
        }
    }
    
    func congratulationAnswerIsCorrect() {
        let ac = UIAlertController(title: "Well done!", message: "Right, '\(slectedWord!)' is the correct answer", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
    
    @objc func getRandWord() -> String? {
        // Select a random word from the array, its length should be >= 3
        while let word = allWords.randomElement() {
            DispatchQueue.main.async { [weak self] in
                // Remove the selected word
                self?.allWords.removeAll{$0 == word}
            }

            if isReal(word: word) {
                return word
            }
        }
        return nil
    }
    
    func isReal(word: String) -> Bool {
        // Check that the given word is a real English word
        let wordLen = word.utf16.count
        
        if wordLen < 3 || wordLen > 15 {
            return false
        }
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: wordLen)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
