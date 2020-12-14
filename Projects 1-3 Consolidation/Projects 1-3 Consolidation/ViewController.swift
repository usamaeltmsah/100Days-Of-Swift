//
//  ViewController.swift
//  Projects 1-3 Consolidation
//
//  Created by Usama Fouad on 12/14/20.
//

import UIKit

class ViewController: UITableViewController {
    
    var flags = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        for item in items {
            if item.hasSuffix(".png") {
                flags.append(item)
            }
        }
        
        flags.sort()
        print(flags.count)
    }


}

