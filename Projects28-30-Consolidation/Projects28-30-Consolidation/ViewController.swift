//
//  ViewController.swift
//  Projects28-30-Consolidation
//
//  Created by Usama Fouad on 15/02/2021.
//

import LocalAuthentication
import UIKit

class ViewController: UICollectionViewController {
    var cardsPairs = [CardsPair]()
    var pairsForGame = ArraySlice<CardsPair>()
    var allCards = [Card]()
    
    var faceUpCardsIdx = [Int]()
    
    var lastCell: CardCell!
    var lastCard: Card!
    
    let NUM_OF_PAIRS = 6
    
    var scoreLabel: UILabel!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Memory Game 🤔"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(viewCardsManager))
        
        if let navigationBar = self.navigationController?.navigationBar {
            let scoreFrame = CGRect(x: 10, y: 0, width: navigationBar.frame.width/2, height: navigationBar.frame.height)

            scoreLabel = UILabel(frame: scoreFrame)
            scoreLabel.text = "Score: 0"

            navigationBar.addSubview(scoreLabel)
        }
        
        cardsPairs.append(CardsPair(card: Card(context: "France"), matching: Card(context: "Paris")))
        cardsPairs.append(CardsPair(card: Card(context: "😂")))
        cardsPairs.append(CardsPair(card: Card(context: "😎")))
        cardsPairs.append(CardsPair(card: Card(context: "🙆")))
        cardsPairs.append(CardsPair(card: Card(context: "Egypt"), matching: Card(context: "Cairo")))
        cardsPairs.append(CardsPair(card: Card(context: "Hello"), matching: Card(context: "مرحباً")))
        cardsPairs.append(CardsPair(card: Card(context: "🤡")))
        cardsPairs.append(CardsPair(card: Card(context: "👻")))
        
        loadGame(nil)
    }
    
    @objc func loadGame(_ action : UIAlertAction!) {
        allCards.removeAll()
        faceUpCardsIdx.removeAll()
        score = 0
        
        cardsPairs.shuffle()
        pairsForGame = cardsPairs.prefix(NUM_OF_PAIRS)
        
        for pair in pairsForGame {
            pair.card.match(with: pair.matching)
            allCards.append(pair.card)
            allCards.append(pair.matching)
        }
        
        for card in allCards {
            card.isFaceUp = false
        }
        
        allCards.shuffle()
        collectionView.reloadData()
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
        } else {
            cell.cardContext.font = UIFont.systemFont(ofSize: 35, weight: .bold)
        }
        
        cell.cardView.isHidden = false
        cell.hideCard()
        
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
                        cell?.cardView.isHidden = true
                        self.lastCell.cardView.isHidden = true
                        
                        self.score += 1
                        
                        if self.score == self.pairsForGame.count {
                            self.showYouWin()
                        }
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
    
    func showYouWin() {
        let ac = UIAlertController(title: "You Win!", message: nil, preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "New Game!", style: .default, handler: loadGame))
        ac.addAction(UIAlertAction(title: "Cancel", style: .default))
        
        present(ac, animated: true)
    }
    
    @objc func viewCardsManager() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {[weak self] success,authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.openView()
                    } else {
                        self?.enterPassword()
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device isn't configured for biometric authentication.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
    }

    func openView() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "CardsManager") as? CardsManagerViewController {
            vc.delegate = self
            scoreLabel.isHidden = true
            if let navigator = navigationController {
                navigator.pushViewController(vc, animated: true)
            }
        }
    }
    
    func enterPassword() {
        let ac = UIAlertController(title: "Authentication failed!", message: "You couldn't be verified; please try again.", preferredStyle: .alert)
        
        ac.addTextField()
        ac.textFields?[0].isSecureTextEntry = true
        ac.textFields?[0].keyboardType = .numberPad
        let submitAction = UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let password = ac?.textFields?[0].text else { return }
            self?.check(password: password)
        }
        ac.addAction(submitAction)
        
        present(ac, animated: true)
    }
    
    func check(password: String?) {
        if password == "123456" {
            openView()
        } else {
            let ac = UIAlertController(title: "Wrong password", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Try again", style: .default, handler: {[weak self] _ in
                self?.enterPassword()
            }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .default))
            present(ac, animated: true)
        }
    }

}

