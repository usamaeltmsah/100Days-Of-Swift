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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return allProperties.keys.count
    }
        
    // There is just one row in every section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return cellSpacingHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? CellController {
            let index = self.allProperties.index(allProperties.startIndex, offsetBy: indexPath.section)
            let key = allProperties.keys[index]
            let value = allProperties.values[index]
            cell.keyLabel?.text = key.uppercased()
            cell.setValue(value: value)
            cell.addBordrs()
            
            return cell
        }
        return CellController()
    }
    
    @objc func shareTapped() {
        let sharedData = getStringDataOfCountry()
        
        let vc = UIActivityViewController(activityItems: sharedData, applicationActivities: [])
        
        vc.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        present(vc, animated: true)
    }

}
