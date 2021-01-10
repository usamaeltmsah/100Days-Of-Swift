//
//  GameScene.swift
//  Project14
//
//  Created by Usama Fouad on 10/01/2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var slots = [WhackSlot]()
    var gameScore: SKLabelNode!
    var numRounds = 0
    
    var popupTime = 0.85
    
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        for i in 0..<5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 410)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 320)) }
        for i in 0..<5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 230)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 140)) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.createEnemy()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            // Get the grand parent of the current node
            guard let whackSlot = node.parent?.parent as? WhackSlot else { continue }
            
            if !whackSlot.isVisible { continue }
            if whackSlot.isHit { continue }
            whackSlot.hit()
            
            if node.name == "charFriend" {
                // They shouldn't have whacked this penguin
                
                score -= 5
                
                run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
            } else if node.name == "charEnemy" {
                // They should have whacked this penguin
                
                whackSlot.charNode.xScale = 0.85
                whackSlot.charNode.yScale = 0.85
                
                score += 1
                
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                
                if let smokeParticles = SKEmitterNode(fileNamed: "smoke.sks") {
                    smokeParticles.position = whackSlot.position
                    addChild(smokeParticles)
                }
            }
        }
    }
    
    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
    
    func createEnemy() {
        numRounds += 1
        
        if numRounds >= 30 {
            for slot in slots {
                slot.hide()
            }
            
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 512, y: 384)
            gameOver.zPosition = 1
            
            let gameOverScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
            gameOverScoreLabel.text = gameScore.text
            gameOverScoreLabel.fontSize = 80
            gameOverScoreLabel.position = CGPoint(x: 512, y: 260)
            gameOverScoreLabel.zPosition = 1
            
            run(SKAction.playSoundFileNamed("gmeOver.m4a", waitForCompletion: false))
            
            addChild(gameOver)
            addChild(gameOverScoreLabel)
            return
        }
        
        popupTime *= 0.991
        
        slots.shuffle()
        slots[0].show(hidTime: popupTime)
        
        if Int.random(in: 0...12) > 4 { slots[1].show(hidTime: popupTime) }
        if Int.random(in: 0...12) > 8 { slots[2].show(hidTime: popupTime) }
        if Int.random(in: 0...12) > 10 { slots[3].show(hidTime: popupTime) }
        if Int.random(in: 0...12) > 11 { slots[4].show(hidTime: popupTime) }
        
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2
        
        let delay = Double.random(in: minDelay...maxDelay)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.createEnemy()
        }
    }
}
