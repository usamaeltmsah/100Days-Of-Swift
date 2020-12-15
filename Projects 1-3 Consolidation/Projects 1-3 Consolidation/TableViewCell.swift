//
//  TableViewCell.swift
//  Projects 1-3 Consolidation
//
//  Created by Usama Fouad on 15/12/2020.
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet var flagImgView: UIImageView!
    @IBOutlet var countryName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        flagImgView?.layer.cornerRadius = (flagImgView?.bounds.width)! / 3
        
        flagImgView?.addBorders(width: 1.5, color: UIColor.black.cgColor)
    }

}
