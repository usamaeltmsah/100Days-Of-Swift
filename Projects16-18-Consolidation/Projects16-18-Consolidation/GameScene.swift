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
    
    var bullet: SKSpriteNode!
    var touchedOneTime = false
    
    
    let goodTargets = ["target3", "target5"]
    let dangerousTargets = ["dangerous_target1", "dangerous_target2"]
        
    var remainingTimeLabel: SKLabelNode!
    var remainingTimeValue = 60 {
        didSet {
            remainingTimeLabel.text = "Time left: \(remainingTimeValue)"
        }
    }
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
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
        sniper.size = CGSize(width: sniper.size.width / 2, height: sniper.size.height / 2)
        sniper.zPosition = 10
        addChild(sniper)
        
        remainingTimeLabel = SKLabelNode(fontNamed: "Chalkduster")
        remainingTimeLabel.fontSize = 40
        remainingTimeLabel.zPosition = 1
        remainingTimeLabel.position = CGPoint(x: 160, y: 724)
        remainingTimeLabel.text = "Time left: \(remainingTimeValue)"
        addChild(remainingTimeLabel)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontSize = 50
        scoreLabel.zPosition = 1
        scoreLabel.fontColor = .magenta
        scoreLabel.position = CGPoint(x: 880, y: 724)
        scoreLabel.text = "Score: \(score)"
        addChild(scoreLabel)
        
        addTarget()
        
        countDown()
    }
    
    func createTarget(at position: CGPoint) {
        let row = Row()
        row.configure(at: position)
        addChild(row)
    }
    
    func countDown() {
        let wait = SKAction.wait(forDuration: 1) // Wait for a second!
        let block = SKAction.run({ [unowned self] in
            if self.remainingTimeValue > 0{
                self.remainingTimeValue -= 1
            } else {
                self.removeAction(forKey: "countdown")
            }
        })
        let sequence = SKAction.sequence([wait, block])

        run(SKAction.repeatForever(sequence), withKey: "countdown")
    }
    
    func addTarget() {
        /**
         - Create targets and but them on the rows.
         - If the player shoots a good target he will get score.
         - Else if he shoots a bad target or a free space he will lose score.
         - Every type of shoot will have difftren sound, and when the bullet drop on the ground, another sound will be played.
         */
        let rowNum = Int.random(in: -1...1)
        let xPos: CGFloat = 900
        createTarget(at: CGPoint(x: xPos, y: centerPoint.y + CGFloat(rowNum)*150.0))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if nodes(at: location).contains(sniper) {
            isSniperTouched = true
        }
        touchedOneTime = true
    }
    
    func createBullet() {
        bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.height*0.2)
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.contactTestBitMask = bullet.physicsBody?.collisionBitMask ?? 0
        bullet.yScale = 0.1
        bullet.zPosition = 5
        bullet.position = sniper.position
        bullet.name = "bullet"
        addChild(bullet)
    }
    
    func shoot() {
        createBullet()
        
        let moveUp = SKAction.moveBy(x: 0, y: 30, duration: 0.1)
        let scale = SKAction.scale(to: 0.5, duration: 0)
        let moveDown = SKAction.moveTo(y: 50, duration: 0.3)
        let rotate = SKAction.rotate(byAngle: .pi/2, duration: 0)
        
        let wait = SKAction.wait(forDuration: 0.25)
        let sequence = SKAction.sequence([moveUp, moveDown, scale, rotate, wait])
        
        bullet.run(sequence, completion: {
            self.bullet.removeAllActions()
            self.bullet.removeFromParent()
        })
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if location.y < 150 {
            location.y = 150
        } else if location.y > 618 {
            location.y = 618
        }
        
        touchedOneTime = false
        
        if isSniperTouched {
            sniper.position = location
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSniperTouched = false
        
        if touchedOneTime {
            shoot()
            touchedOneTime = false
        }
    }
}
