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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return scripts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Script", for: indexPath) as? ScriptCell
        
        cell?.scriptName = Array(scripts.keys)[indexPath.row]
        
        cell?.scriptValue = Array(scripts.values)[indexPath.row]
        
        return cell ?? ScriptCell()
    }

}
