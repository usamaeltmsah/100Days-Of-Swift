//
//  CardCell.swift
//  Projects28-30-Consolidation
//
//  Created by Usama Fouad on 16/02/2021.
//

import UIKit

class CardCell: UICollectionViewCell {
    @IBOutlet var cardContext: UILabel!
    @IBOutlet var cardView: UIView!
    var hiddenView: UIView!
    
    override func awakeFromNib() {
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor.white.cgColor
        hiddenView = UIView(frame: cardView.frame)
        hiddenView.backgroundColor = .systemGreen
        self.addSubview(hiddenView)
    }
    
    func showCard() {
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        
        UIView.transition(with: hiddenView, duration: 1.0, options: transitionOptions, animations: {
            self.hiddenView.isHidden = true
        })

        UIView.transition(with: cardView, duration: 1.0, options: transitionOptions, animations: {
            self.cardView.isHidden = false
            self.cardView.backgroundColor = .orange
            self.cardContext.isHidden = false
        })
    }
    
    func hideCard() {
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromLeft, .showHideTransitionViews]
        
        UIView.transition(with: cardView, duration: 1.0, options: transitionOptions, animations: {
            self.cardView.isHidden = true
        })

        UIView.transition(with: hiddenView, duration: 1.0, options: transitionOptions, animations: {
            self.hiddenView.isHidden = false
            self.hiddenView.backgroundColor = UIColor.systemGreen
        })
    }

}
