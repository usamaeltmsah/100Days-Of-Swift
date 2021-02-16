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
    
    var faceUpCardsIdx = [Int]()
    
    var lastCell: CardCell!
    var lastCard: Card!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        cardsPairs.append(CardsPair(card: Card(context: "France"), matching: Card(context: "Paris")))
        cardsPairs.append(CardsPair(card: Card(context: "😂")))
        cardsPairs.append(CardsPair(card: Card(context: "😎")))
        cardsPairs.append(CardsPair(card: Card(context: "🙆")))
        cardsPairs.append(CardsPair(card: Card(context: "Egypt"), matching: Card(context: "Cairo")))
        cardsPairs.append(CardsPair(card: Card(context: "Hello"), matching: Card(context: "مرحباً")))
        
        for pair in cardsPairs {
            pair.card.match(with: pair.matching)
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
        cell.cardContext.isHidden = true
        
        if card.context.count < 2 {
            cell.cardContext.font = UIFont.systemFont(ofSize: 100)
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? CardCell
        
        let card = allCards[indexPath.item]
        if !card.isFaceUp && faceUpCardsIdx.count < 2 {
            cell?.showCard()
            allCards[indexPath.item].flip()
            faceUpCardsIdx.append(indexPath.item)
            
            if faceUpCardsIdx.count >= 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if card.isMatchWith(card: self.lastCard) {
                        cell?.isHidden = true
                        self.lastCell.isHidden = true
                    } else {
                        cell?.hideCard()
                        self.lastCell?.hideCard()
                        self.flipCards()
                    }
                    self.faceUpCardsIdx.removeAll()
                }
            } else {
                lastCell = cell
                lastCard = card
            }
        }
    }
    
    func flipCards() {
        for cardIdx in self.faceUpCardsIdx {
            allCards[cardIdx].flip()
        }
    }


}

