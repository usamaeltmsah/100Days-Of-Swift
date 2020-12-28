//
//  ViewController.swift
//  Projects 7-9 Consolidation
//
//  Created by Usama Fouad on 28/12/2020.
//

import UIKit

class ViewController: UIViewController {
    var allWords = [String]()
    var usedWords = [String]()
    var word: String!
    
    override func loadView() {
        if let startWordsURL = Bundle.main.url(forResource: "words", withExtension: "txt") {
            if let words = try? String(contentsOf: startWordsURL) {
                allWords = words.components(separatedBy: "\n")
            }
        }
    }
    
    @objc func getRandWord() {
        // Select a random word from the array, its length should be >= 3
        while let word = allWords.randomElement() {
            // Remove the selected word
            allWords.removeAll{$0 == word}

            if word.count >= 3 {
                self.word = word
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performSelector(inBackground: #selector(getRandWord), with: nil)
    }


}

