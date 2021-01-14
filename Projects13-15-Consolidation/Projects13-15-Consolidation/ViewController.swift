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
        performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
    }
    
    @objc func showError() {
        let ac = UIAlertController(title: "Loading Error ", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()

        if let jsonCountries = try? decoder.decode([Country].self, from: json) {
            countries = jsonCountries
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }
        allCountries = countries
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let country = countries[indexPath.row]
        cell.textLabel?.text = country.name
        cell.detailTextLabel?.text = "Population: \(Float(country.population)/1000000.0) Milion people"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            vc.details = countries[indexPath.row]
            vc.title = countries[indexPath.row].name
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func promptForText() {
        let ac = UIAlertController(title: "Filter Countries", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .default))
        
        let submitAction = UIAlertAction(title: "Filter", style: .default) { [weak self, weak ac] _ in
            guard let text = ac?.textFields?[0].text else { return }
            self?.filter(text)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func filter(_ text: String) {
        filteredCountries = []
        for country in allCountries {
            if searchIn(countrynObject: country, text: text.lowercased()) {
                filteredCountries.append(country)
            }
        }
        countries = filteredCountries
        DispatchQueue.main.async {
            self.title = text.uppercased()
        }
        tableView.reloadData()
    }

    func searchIn(countrynObject: Country, text: String) -> Bool {
        return countrynObject.name.lowercased().range(of:text) != nil || countrynObject.capital.lowercased().range(of:text) != nil
    }
    
    @objc func refreshPage() {
        countries = allCountries
        tableView.reloadData()
        DispatchQueue.main.async {
            self.title = ""
        }
    }
}

