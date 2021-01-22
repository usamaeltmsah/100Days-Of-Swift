//
//  ScriptsController.swift
//  Extension
//
//  Created by Usama Fouad on 22/01/2021.
//

import UIKit

class ScriptsController: UITableViewController {
    // Each script has a name and its content
//    var scripts: [String:String] = [:]
    
    struct allScripts {
        static var scripts: [String:String] = [:]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addScript))
        
        loadScripts()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return allScripts.scripts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Script", for: indexPath)
        
        cell.textLabel?.text = Array(allScripts.scripts.keys)[indexPath.row]
                
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "ScriptDetail") as? ScriptViewController {
            //Confirming delegate
            vc.delegate = self
            
            let name = Array(allScripts.scripts.keys)[indexPath.row]
            vc.scriptName = name
            vc.scriptValue = allScripts.scripts[name]!
            
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
    
    func loadScripts() -> [String:String] {
        let defaults = UserDefaults.standard
        
        if let data = defaults.object(forKey: "scripts") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                allScripts.scripts = try jsonDecoder.decode([String:String].self, from: data)
                print(allScripts.scripts)
            } catch {
                allScripts.scripts["Get current site title"] = "alert(document.title)"
                allScripts.scripts["Get current date"] = "alert(Date());"
                allScripts.scripts["Get Random Number between 1 and 10000"] = "alert(Math.floor(Math.random() * 10000) + 1);"
                allScripts.scripts["Sorting array"] = """
                    // Be free to edit the array's values
                        var PLs = ['C++', 'Java', 'Python', 'Swift', 'Ruby'];
                        alert(PLs.sort());
                    """
                allScripts.scripts["Math multiplication"] = """
                    var x = 15;
                    var y = 3;
                    var z = x * y;
                    alert(x + " * " + y + " = " + z);
                    """
            }
        }
        return allScripts.scripts
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(allScripts.scripts) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "scripts")
        } else {
            print("Failed to save data")
        }
    }
    
    func add(key:String, value: String) {
        allScripts.scripts[key] = value
    }
    
    func rename(oldKey: String, newKey: String, value: String) {
        if (allScripts.scripts.removeValue(forKey: oldKey) != nil) {
            allScripts.scripts[newKey] = value
        }
    }
}
