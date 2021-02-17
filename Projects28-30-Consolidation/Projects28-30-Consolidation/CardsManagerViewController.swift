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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCardsPair))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.cardsPairs.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let card = delegate?.cardsPairs[indexPath.row]
        
        cell.textLabel?.text = "Card: \(card?.card.context ?? "") : Matching: \(card?.matching.context ?? "")"
        
        return cell
    }
    
    @objc func addCardsPair() {
        let ac = UIAlertController(title: "Add cards", message: nil, preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.placeholder = "Card"
        }
        ac.addTextField { (textField) in
            textField.placeholder = "Matching"
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        let appendAction = UIAlertAction(title: "Add", style: .default) { [weak self, weak ac] _ in
            guard let card = ac?.textFields?[0].text else { return }
            guard var matching = ac?.textFields?[1].text else { return }
            guard card != "" else { return }
            
            if matching == "" {
                matching = card
            }
            self?.delegate?.cardsPairs.append(CardsPair(card: Card(context: card, matching: matching)))
            self?.tableView.reloadData()
        }
        
        ac.addAction(appendAction)
        
        present(ac, animated: true)
    }

}
