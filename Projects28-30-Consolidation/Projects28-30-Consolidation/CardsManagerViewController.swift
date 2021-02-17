//
//  CardsManagerViewController.swift
//  Projects28-30-Consolidation
//
//  Created by Usama Fouad on 17/02/2021.
//

import UIKit

class CardsManagerViewController: UITableViewController {
    
    var delegate: ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.cardsPairs.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let card = delegate?.cardsPairs[indexPath.row]
        
        cell.textLabel?.text = "\(card?.card.context ?? "") : \(card?.matching.context ?? "")"
        
        return cell
    }

}
