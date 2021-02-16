//
//  ViewController.swift
//  Projects28-30-Consolidation
//
//  Created by Usama Fouad on 15/02/2021.
//

import UIKit

class ViewController: UICollectionViewController {
    var cardsPairs = [CardsPair]()
    var allCards = [Card]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        cardsPairs.append(CardsPair(card: Card(context: "France"), matching: Card(context: "Paris")))
        cardsPairs.append(CardsPair(card: Card(context: "😂")))
        cardsPairs.append(CardsPair(card: Card(context: "👨‍👨‍👦")))
        cardsPairs.append(CardsPair(card: Card(context: "Egypt"), matching: Card(context: "Cairo")))
        
        for pair in cardsPairs {
            allCards.append(pair.card)
            allCards.append(pair.matching)
        }
        
        allCards.shuffle()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allCards.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Card", for: indexPath) as? CardCell else {
            fatalError("Can't create a card")
        }
        let card = allCards[indexPath.item]
        cell.cardContext.text = card.context
        
        if card.context.count < 2 {
            cell.cardContext.font = UIFont.systemFont(ofSize: 100)
        }
        
        return cell
    }


}

