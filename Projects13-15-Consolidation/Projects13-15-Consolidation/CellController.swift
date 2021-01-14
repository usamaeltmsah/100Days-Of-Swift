//
//  CellController.swift
//  Projects13-15-Consolidation
//
//  Created by Usama Fouad on 13/01/2021.
//

import UIKit

class CellController: UITableViewCell {
    @IBOutlet var keyLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .random
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0.1...1), green: .random(in: 0.1...1), blue: .random(in: 0.1...1), alpha: .random(in: 0...1))
    }
}

