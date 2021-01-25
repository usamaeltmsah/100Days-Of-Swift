//
//  DetailViewController.swift
//  Projects19-21 Consolidation
//
//  Created by Usama Fouad on 25/01/2021.
//

import UIKit

class DetailViewController: UIViewController {

    var note: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = note?.name
        navigationItem.largeTitleDisplayMode = .never
    }

}
