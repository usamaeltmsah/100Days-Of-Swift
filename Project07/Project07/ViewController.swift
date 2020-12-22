//
//  ViewController.swift
//  Project07
//
//  Created by Usama Fouad on 22/12/2020.
//

import UIKit

class ViewController: UITableViewController {
    var petition = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petition.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = "Title goes here!"
        cell.detailTextLabel?.text = "Subtitle goes here!"
        
        return cell
    }

}

