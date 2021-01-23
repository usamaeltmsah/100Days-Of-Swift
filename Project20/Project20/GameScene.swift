//
//  GameScene.swift
//  Project20
//
//  Created by Usama Fouad on 23/01/2021.
//

import SpriteKit

class GameScene: SKScene {
    var gameTimer: Timer?
    var fireWorks = [SKNode]()
    
    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22
    
    var score = 0 {
        didSet {
            
        }
    }
    
    override func didMove(to view: SKView) {
        
    }
}
