//
//  Row.swift
//  Projects16-18-Consolidation
//
//  Created by Usama Fouad on 19/01/2021.
//

import SpriteKit

class Target: SKNode {
    var charNode: SKSpriteNode!
    
    let goodTargets = ["target1", "target2", "target3", "target4"]
    let dangerousTargets = ["dangerous_target1", "dangerous_target2"]
    
    let centerPoint = CGPoint(x: 512, y: 384)
    
    func configure(at position: CGPoint) {
        self.position = position
        
        let size = CGSize(width: 150, height: 150)
        
        let type = Int.random(in: 0...1)
        
        if type == 0 {
            charNode = SKSpriteNode(imageNamed: goodTargets.randomElement()!)
            charNode.name = "goodTarget"
        } else {
            charNode = SKSpriteNode(imageNamed: dangerousTargets.randomElement()!)
            charNode.name = "dangerousTarget"
        }
        charNode.size = size
        
        let rand = CGFloat.random(in: 0.3...1)
        charNode.xScale = rand
        charNode.yScale = rand
        charNode.physicsBody = SKPhysicsBody(circleOfRadius: charNode.size.height * rand)
        charNode.physicsBody?.contactTestBitMask = 1
        addChild(charNode)
        
        let duration = Double.random(in: 2...10)
        let move = SKAction.moveTo(x: -800, duration: duration)
        charNode.run(move, completion: {
            self.charNode.removeAllActions()
            self.charNode.removeFromParent()
        })
    }
}

