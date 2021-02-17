//
//  Card.swift
//  Projects28-30-Consolidation
//
//  Created by Usama Fouad on 16/02/2021.
//

import Foundation

class Card : NSObject, Codable {
    var context: String
    
    var isFaceUp = false
    var isMatched = false
    var matching: String!
    
    init(context: String, matching: String) {
        self.context = context
        self.matching = matching
    }
    
    init(context: String) {
        self.context = context
        self.matching = context
    }
    
    func match(with card: Card) {
        self.matching = card.context
        card.matching = self.context
    }
    
    func flip() {
        isFaceUp.toggle()
    }
    
    func isMatchWith(card: Card) -> Bool {
        return matching == card.context
    }
}
