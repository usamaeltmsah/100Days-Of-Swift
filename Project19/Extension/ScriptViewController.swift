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
        
        title = scriptName
        scriptTextView.text = scriptValue
    }
}
