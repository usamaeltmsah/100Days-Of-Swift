//
//  imgCell.swift
//  Project1
//
//  Created by Usama Fouad on 01/01/2021.
//

import UIKit

class imgCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var imageName: UILabel!
    @IBOutlet var visitsCount: UILabel!
    
    var visits = 0 {
        didSet {
            visitsCount.text = "\(visits)"
        }
    }
}
