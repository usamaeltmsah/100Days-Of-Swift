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
    }

}
