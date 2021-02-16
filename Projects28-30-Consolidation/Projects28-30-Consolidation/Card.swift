//
//  Card.swift
//  Projects28-30-Consolidation
//
//  Created by Usama Fouad on 16/02/2021.
//

import Foundation

struct Card {
    let context: String
    
    var isFaceUp = false
    var isMatched = false
    
    init(context: String) {
        self.context = context
    }
    
    mutating func flip() {
        isFaceUp.toggle()
    }
}
