//
//  DetailViewController.swift
//  Projects13-15-Consolidation
//
//  Created by Usama Fouad on 13/01/2021.
//

import UIKit

class DetailViewController: UITableViewController {
    var details: Country?
    var properites: Mirror.Children?
    var allProperties = [String:Any]()
    
    let cellSpacingHeight: CGFloat = 5.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.tableView.estimatedRowHeight = 50
//        self.tableView.rowHeight = UITableView.automaticDimension
        
        navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        performSelector(inBackground: #selector(addCountriesDataToDictionary), with: nil)
    }
    
    @objc func addCountriesDataToDictionary(){
        var mirror: Mirror?
        if let details = details {
            mirror = Mirror(reflecting: details)
        }
        if let properites = mirror?.children {
            for property in properites {
                if let key = property.label {
                    let value = property.value
                    allProperties[key] = value
                }
            }
        }
    }

}
