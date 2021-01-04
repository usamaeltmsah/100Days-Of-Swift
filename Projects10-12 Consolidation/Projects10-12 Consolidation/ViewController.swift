//
//  ViewController.swift
//  Projects10-12 Consolidation
//
//  Created by Usama Fouad on 04/01/2021.
//

import UIKit

class ViewController: UITableViewController {

    var things = [ThingCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return things.count
    }

}

