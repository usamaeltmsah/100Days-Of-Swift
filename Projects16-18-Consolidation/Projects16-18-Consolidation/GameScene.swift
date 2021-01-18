//
//  GameScene.swift
//  Projects16-18-Consolidation
//
//  Created by Usama Fouad on 18/01/2021.
//

import SpriteKit
class GameScene: SKScene {
    var background: SKSpriteNode!
    var sniper: SKSpriteNode!
    var isSniperTouched = false
    
    var levelTimerLabel: SKLabelNode!

    var levelTimerValue: Int = 60 {
        didSet {
            levelTimerLabel.text = "Time left: \(levelTimerValue)"
        }
    }
    
    let centerPoint = CGPoint(x: 512, y: 384)
    
    override func didMove(to view: SKView) {
        background = SKSpriteNode(imageNamed: "background")
        background.position = centerPoint
        background.size = (self.view?.bounds.size)!
        background.zPosition = -1
        addChild(background)
        
        sniper = SKSpriteNode(imageNamed: "sniper")
        sniper.position = centerPoint
        addChild(sniper)
        
        levelTimerLabel = SKLabelNode(fontNamed: "Chalkduster")
        levelTimerLabel.fontSize = 40
        levelTimerLabel.zPosition = 1
        levelTimerLabel.position = CGPoint(x: 160, y: 724)
        levelTimerLabel.text = "Time left: \(levelTimerValue)"
        addChild(levelTimerLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if nodes(at: location).contains(sniper) {
            isSniperTouched = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if location.y < 150 {
            location.y = 150
        } else if location.y > 618 {
            location.y = 618
        }
        
        if isSniperTouched {
            sniper.position = location
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSniperTouched = false
    }
}
