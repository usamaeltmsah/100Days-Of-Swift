//
//  ViewController.swift
//  Projects10-12 Consolidation
//
//  Created by Usama Fouad on 04/01/2021.
//

import UIKit

class ViewController: UITableViewController, UIImagePickerControllerDelegate,  UINavigationControllerDelegate {

    var things = [Thing]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return things.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "thingCell", for: indexPath) as? ThingCell else {
            fatalError("Unable to dequeue a ThingCell")
        }
        
        let thing = things[indexPath.row]

        cell.captionLabel.text = thing.caption

            cell.thingImage.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
            cell.thingImage.layer.borderWidth = 2
            cell.thingImage.layer.cornerRadius = 3
            cell.layer.cornerRadius = 7
        
        return cell
    }

}

