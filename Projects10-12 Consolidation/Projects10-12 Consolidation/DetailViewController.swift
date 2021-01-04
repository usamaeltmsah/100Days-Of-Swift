//
//  DetailViewController.swift
//  Projects10-12 Consolidation
//
//  Created by Usama Fouad on 04/01/2021.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var thingImageView: UIImageView!
    @IBOutlet var thingCaption: UILabel!
    
    var imagePath: String!
    var caption: String!
    
    override func viewDidLoad() {
        if let imagePath = imagePath {
            thingImageView.image = UIImage(contentsOfFile: imagePath)
        }
        if let caption = caption {
            thingCaption.text = caption
        }
    }
}
