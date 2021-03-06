//
//  ScriptViewController.swift
//  Extension
//
//  Created by Usama Fouad on 22/01/2021.
//

import UIKit

class ScriptViewController: UIViewController {
    @IBOutlet var scriptTextView: UITextView!
    var scriptName: String = ""
    var scriptValue: String = ""
    
    var delegate: ScriptsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        title = scriptName
        scriptTextView.text = scriptValue
    }
    
    @objc func save() {
        scriptValue = scriptTextView.text
        renameScript()
    }
    
    func renameScript() {
        var rename = false
        let ac = UIAlertController(title: "Rename script", message: nil, preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.text = self.scriptName
        }
        
        let oldName = ac.textFields?[0].text
        
        if oldName?.count ?? 0 > 0 {
            rename = true
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return }
            self?.scriptName = newName
            
            self?.title = newName
            
            if rename {
                self?.delegate?.rename(oldKey: oldName!, newKey: newName, value: self!.scriptValue)
            } else {
                self?.delegate?.add(key: newName, value: self!.scriptValue)
            }
            
            self?.delegate?.save()
            self?.delegate?.tableView.reloadData()
            self?.navigationController?.popViewController(animated: true)
        }
        
        ac.addAction(saveAction)
        
        present(ac, animated: true)
    }
}
