//
//  ViewController.swift
//  Project07
//
//  Created by Usama Fouad on 22/12/2020.
//

import UIKit

class ViewController: UITableViewController {
    var petitions = [Petition]()
    var allPetitions = [Petition]()
    var filteredPetitions = [Petition]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let filterButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(promptForText))
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshPage))
        
        navigationItem.leftBarButtonItems = [refreshButton, filterButton]
        
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        } else {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
        }
        let credits = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(dataComesFrom))
        
        navigationItem.rightBarButtonItem = credits
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    self?.parse(json: data)
                    return
                }
            }
            self?.showError()
        }
    }
    
    func showError() {
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(title: "Loading Error ", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(ac, animated: true)
        }
    }
    
    @objc func dataComesFrom() {
        let ac = UIAlertController(title: "Data Source", message: "This data comes from the \"We The People API of the Whitehouse\".", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
        allPetitions = petitions
    }
    
    @objc func promptForText() {
        let ac = UIAlertController(title: "Filter Petition", message: nil, preferredStyle: .alert)
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
        filteredPetitions = []
        for petition in allPetitions {
            if searchIn(petitionObject: petition, text: text.lowercased()) {
                filteredPetitions.append(petition)
            }
        }
        petitions = filteredPetitions
        DispatchQueue.main.async {
            self.title = text
        }
        tableView.reloadData()
        // Allow the user to search in all the petitions, even if he searched before
    }

    func searchIn(petitionObject: Petition, text: String) -> Bool {
        return petitionObject.body.lowercased().range(of:text) != nil && petitionObject.title.lowercased().range(of:text) != nil
    }
    
    @objc func refreshPage() {
        petitions = allPetitions
        tableView.reloadData()
        DispatchQueue.main.async {
            self.title = ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = petitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        vc.title = petitions[indexPath.row].title
        navigationController?.pushViewController(vc, animated: true)
    }

}

