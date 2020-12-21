//
//  ViewController.swift
//  Projects 4-6 Consolidation
//
//  Created by Usama Fouad on 21/12/2020.
//

import UIKit

class ViewController: UITableViewController {
    var shoppingList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
    }

}

