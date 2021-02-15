//
//  ViewController.swift
//  Projects28-30-Consolidation
//
//  Created by Usama Fouad on 15/02/2021.
//

import UIKit

class ViewController: UICollectionViewController {
    var cards = [CardsPair]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        cards.append(CardsPair(card: Card(context: "France"), matching: Card(context: "Paris")))
        cards.append(CardsPair(card: Card(context: "😂")))
    }


}

