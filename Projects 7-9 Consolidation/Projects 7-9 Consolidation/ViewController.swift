//
//  ViewController.swift
//  Projects 7-9 Consolidation
//
//  Created by Usama Fouad on 28/12/2020.
//

import UIKit

class ViewController: UIViewController {
    var allWords = [String]()
    
    override func loadView() {
        if let startWordsURL = Bundle.main.url(forResource: "words", withExtension: "txt") {
            if let words = try? String(contentsOf: startWordsURL) {
                allWords = words.components(separatedBy: "\n")
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

