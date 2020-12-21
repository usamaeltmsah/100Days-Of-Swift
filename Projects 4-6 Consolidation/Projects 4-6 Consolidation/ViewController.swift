//
//  ViewController.swift
//  Projects 4-6 Consolidation
//
//  Created by Usama Fouad on 21/12/2020.
//

import UIKit

class ViewController: UITableViewController {
    var shoppingList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        let shareButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareShoppingList))
        
        navigationItem.rightBarButtonItems = [addButton, shareButton]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath)
        cell.textLabel?.text = shoppingList[indexPath.row]
        
        return cell
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter new item", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Add", style: .default) { [weak self, weak ac] _ in
            guard let itemName = ac?.textFields?[0].text else { return }
            self?.addItem(itemName)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func addItem(_ itemName: String) {
        // Add the new item if and only if it didn't added before
        if !shoppingList.contains(where: {$0.caseInsensitiveCompare(itemName) == .orderedSame}) && !itemName.isEmpty {
            shoppingList.insert(itemName, at: 0)
            
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        } else {
            let ac = UIAlertController(title: "Already exists item", message: "Can't add this item cause it's already in the list", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @objc func shareShoppingList() {
        let list = shoppingList.joined(separator: "\n")
        
        let vc = UIActivityViewController(activityItems: [list], applicationActivities: [])
        
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }

}

