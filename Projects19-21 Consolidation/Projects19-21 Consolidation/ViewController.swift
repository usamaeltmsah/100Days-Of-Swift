//
//  ViewController.swift
//  Projects19-21 Consolidation
//
//  Created by Usama Fouad on 25/01/2021.
//

import UIKit

class ViewController: UITableViewController {

    var notes = [Note]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notes"
                
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        
        cell.textLabel?.text = notes[indexPath.row].name
        cell.detailTextLabel?.text = notes[indexPath.row].context
        
        return cell
    }


}

