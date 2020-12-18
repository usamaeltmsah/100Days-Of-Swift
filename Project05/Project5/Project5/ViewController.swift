//
//  ViewController.swift
//  Project5
//
//  Created by Usama Fouad on 18/12/2020.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var userdWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["Silkworm"]
        }
    }


}

