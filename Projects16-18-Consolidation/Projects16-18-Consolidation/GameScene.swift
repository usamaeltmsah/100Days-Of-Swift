//
//  GameScene.swift
//  Projects16-18-Consolidation
//
//  Created by Usama Fouad on 18/01/2021.
//

import SpriteKit
class GameScene: SKScene {
    var background: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.size = (self.view?.bounds.size)!
        background.zPosition = -1
        addChild(background)
    }
}
