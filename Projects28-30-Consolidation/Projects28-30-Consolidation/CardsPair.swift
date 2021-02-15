//
//  CardsPair.swift
//  Projects28-30-Consolidation
//
//  Created by Usama Fouad on 16/02/2021.
//

import UIKit

struct CardsPair {
    let card: Card
    let matching: Card
    
    init(card: Card, matching: Card) {
        self.card = card
        self.matching = matching
    }
    
    init(card: Card) {
        self.card = card
        self.matching = card
    }
}
