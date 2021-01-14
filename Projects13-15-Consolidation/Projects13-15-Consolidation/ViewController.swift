//
//  ViewController.swift
//  Projects13-15-Consolidation
//
//  Created by Usama Fouad on 12/01/2021.
//

import UIKit

class ViewController: UITableViewController {
    var countries = [Country]()
    var allCountries = [Country]()
    var filteredCountries = [Country]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let filterButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(promptForText))
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshPage))
        
        navigationItem.leftBarButtonItems = [refreshButton, filterButton]
        performSelector(inBackground: #selector(fetchJson), with: nil)
    }
    
    @objc func fetchJson() {
        let urlString: String
        
        urlString = "https://restcountries.eu/rest/v2/all"

        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
                return
            }
        }
    }
}

