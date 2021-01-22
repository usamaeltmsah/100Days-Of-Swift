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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        title = scriptName
        scriptTextView.text = scriptValue
    }
    
    @objc func save() {
        renameScript()
        scriptValue = scriptTextView.text
        
        self.reloadInputViews()
    }
    
    func renameScript() {
        let ac = UIAlertController(title: "Rename script", message: nil, preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.text = self.scriptName
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return }
            self?.scriptName = newName
            
            self?.title = newName
        }
        
        ac.addAction(saveAction)
        
        present(ac, animated: true)
    }
}
