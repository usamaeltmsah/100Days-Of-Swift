//
//  ScriptsController.swift
//  Extension
//
//  Created by Usama Fouad on 22/01/2021.
//

import UIKit

class ScriptsController: UITableViewController {
    var scripts: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return scripts.count
    }

}
