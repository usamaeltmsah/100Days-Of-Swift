//
//  ScriptsController.swift
//  Extension
//
//  Created by Usama Fouad on 22/01/2021.
//

import UIKit

class ScriptsController: UITableViewController {
    // Each script has a name and its content
    var scripts: [String:String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addScript))
        
        let defaults = UserDefaults.standard
        
        if let data = defaults.object(forKey: "scripts") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                scripts = try jsonDecoder.decode([String:String].self, from: data)
            } catch {
                print("Failed to load scripts.")
            }
            
        }
        
        if scripts.isEmpty {
            scripts["Get current site title"] = "alert(document.title)"
            scripts["Get current date"] = "alert(Date());"
            scripts["Get Random Number between 1 and 10000"] = "alert(Math.floor(Math.random() * 10000) + 1);"
            scripts["Sorting array"] = """
                // Be free to edit the array's values
                    var PLs = ['C++', 'Java', 'Python', 'Swift', 'Ruby'];
                    alert(PLs.sort());
                """
            scripts["Math multiplication"] = """
                var x = 15;
                var y = 3;
                var z = x * y;
                alert(x + " * " + y + " = " + z);
                """
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return scripts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Script", for: indexPath)
        
        cell.textLabel?.text = Array(scripts.keys)[indexPath.row]
                
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "ScriptDetail") as? ScriptViewController {
            //Confirming delegate
            vc.delegate = self
            
            let name = Array(scripts.keys)[indexPath.row]
            vc.scriptName = name
            vc.scriptValue = scripts[name]!
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func addScript() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ScriptDetail") as? ScriptViewController {
                 //Confirming delegate
                vc.delegate = self
                if let navigator = navigationController {
                    navigator.pushViewController(vc, animated: true)
                }
        }
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(scripts) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "scripts")
        } else {
            print("Failed to save data")
        }
    }
    
    func add(key:String, value: String) {
        scripts[key] = value
    }
    
    func rename(oldKey: String, newKey: String, value: String) {
        if (scripts.removeValue(forKey: oldKey) != nil) {
            scripts[newKey] = value
        }
    }
}
