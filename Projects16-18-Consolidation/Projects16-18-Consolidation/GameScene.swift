//
//  GameScene.swift
//  Projects16-18-Consolidation
//
//  Created by Usama Fouad on 18/01/2021.
//

import SpriteKit
class GameScene: SKScene, SKPhysicsContactDelegate {
    var background: SKSpriteNode!
    var sniper: SKSpriteNode!
    var isSniperTouched = false
    
    var touchedOneTime = false
    
    var remainingTimeLabel: SKLabelNode!
    var remainingTime = 60 {
        didSet {
            remainingTimeLabel.text = "Time left: \(remainingTime)"
            
            if remainingTime <= 0 {
                isGameOver = true
            }
        }
    }
    
    var leftBulletsLabel: SKLabelNode!
    
    var reloadAmmoLabel: SKLabelNode!
    
    var leftBullets = 6 {
        didSet {
            leftBulletsLabel.text = "🚅 \(leftBullets)"
            
            if leftBullets < 2 {
                leftBulletsLabel.fontColor = .red
            } else {
                leftBulletsLabel.fontColor = .white
            }
        }
    }
    
    var playAgainLabel: SKLabelNode!
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    let centerPoint = CGPoint(x: 512, y: 384)
    
    var isGameOver = false
    
    var gameTimer: Timer?
    
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = .zero // Or: CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        play()
    }
    
    func addViews() {
        addBackGround()
        addSniper()
        addRemainingTimeLbl()
        addScoreLbl()
        addBulletsLabel()
        addReloadAmmoLabel()
    }
    
    func resetAll() {
        addViews()
        
        remainingTime = 60
        touchedOneTime = false
        isGameOver = false
        score = 0
        leftBullets = 6
        gameTimer?.invalidate()
    }
    
    func play() {
        removeAllActions()
        removeAllChildren()
        
        resetAll()
        countDown()
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(addTarget), userInfo: nil, repeats: true)
    }
    
    func addBackGround() {
        background = SKSpriteNode(imageNamed: "background")
        background.position = centerPoint
        background.size = (self.view?.bounds.size)!
        background.zPosition = -1
        addChild(background)
    }
    
    func addSniper() {
        sniper = SKSpriteNode(imageNamed: "sniper")
        sniper.position = centerPoint
        sniper.size = CGSize(width: sniper.size.width / 2, height: sniper.size.height / 2)
        sniper.zPosition = 10
        addChild(sniper)
    }
    
    func addRemainingTimeLbl() {
        remainingTimeLabel = SKLabelNode(fontNamed: "Chalkduster")
        remainingTimeLabel.fontSize = 40
        remainingTimeLabel.zPosition = 1
        remainingTimeLabel.position = CGPoint(x: 160, y: 724)
        remainingTimeLabel.text = "Time left: \(remainingTime)"
        addChild(remainingTimeLabel)
    }
    
    func addScoreLbl() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontSize = 50
        scoreLabel.zPosition = 1
        scoreLabel.fontColor = .magenta
        scoreLabel.position = CGPoint(x: 880, y: 724)
        scoreLabel.text = "Score: \(score)"
        addChild(scoreLabel)
    }
    
    func addBulletsLabel() {
        leftBulletsLabel = SKLabelNode(fontNamed: "Chalkduster")
        leftBulletsLabel.position = CGPoint(x: 950, y: 650)
        leftBulletsLabel.zPosition = 10
        addChild(leftBulletsLabel)
    }
    
    func addReloadAmmoLabel() {
        reloadAmmoLabel = SKLabelNode(text: "🔫")
        reloadAmmoLabel.fontSize = 50
        reloadAmmoLabel.position = CGPoint(x: 950, y: 600)
        reloadAmmoLabel.zPosition = 10
        addChild(reloadAmmoLabel)
    }
    
    func createTarget(at position: CGPoint) {
        let target = Target()
        target.configure(at: position)
        addChild(target)
    }
    
    func countDown() {
        let wait = SKAction.wait(forDuration: 1) // Wait for a second!
        let block = SKAction.run({ [unowned self] in
            if self.remainingTime > 0{
                self.remainingTime -= 1
            } else {
                self.removeAction(forKey: "countdown")
            }
        })
        let sequence = SKAction.sequence([wait, block])

        run(SKAction.repeatForever(sequence), withKey: "countdown")
    }
    
    @objc func addTarget() {
        if isGameOver { return }
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
            if isGameOver {
                playAgain()
                if nodes(at: location).contains(playAgainLabel) {
                    play()
                    return
                }
            }
        }
        touchedOneTime = true
    }
    
    func createBullet() -> SKNode {
        let scale:CGFloat = 0.1
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.height*scale)
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.contactTestBitMask = 1
        bullet.yScale = scale
        bullet.zPosition = 5
        bullet.position = sniper.position
        bullet.name = "bullet"
        addChild(bullet)
        return bullet
    }
    
    func sound(_ fileName: String) -> SKAction {
        return SKAction.playSoundFileNamed(fileName, waitForCompletion: false)
    }
    
    func shoot() {
        let bullet = createBullet()
        // Run shooting sound when bullet created.
        run(sound("bulletFlyBy.m4a"))
        let moveUp = SKAction.moveBy(x: 0, y: 30, duration: 0.1)
        let scale = SKAction.scale(to: 0.5, duration: 0)
        let moveDown = SKAction.moveTo(y: 50, duration: 0.3)
        let rotate = SKAction.rotate(byAngle: .pi/2, duration: 0)
        let changeScore = SKAction.run {
            self.makeFlyingScore(5.00000000001, increase: false)
            self.score -= 5
        }
        let bulletDropSound = sound("bulletDrop.m4a")
        let wait = SKAction.wait(forDuration: 0.25)
        let sequence = SKAction.sequence([moveUp, changeScore, moveDown, scale, rotate, bulletDropSound, wait])
        
        bullet.run(sequence, completion: {
            bullet.removeAllActions()
            bullet.removeFromParent()
        })
        leftBullets -= 1
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
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if nodes(at: location).contains(reloadAmmoLabel) {
            run(sound("bulletLoadInMagazine.m4a"))
            leftBullets = 6
            return
        }
        
        isSniperTouched = false
        
        if touchedOneTime && !isGameOver && leftBullets > 0 {
            shoot()
            touchedOneTime = false
        }
    }
    
    func makeFlyingScore(_ score: CGFloat, increase: Bool) {
        let flyingScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        flyingScoreLabel.fontSize = 30
        flyingScoreLabel.zPosition = 1
        if increase {
            flyingScoreLabel.fontColor = .green
            flyingScoreLabel.text = "+\(score)"
        } else {
            flyingScoreLabel.fontColor = .red
            flyingScoreLabel.text = "-\(score)"
        }
        
        flyingScoreLabel.position = CGPoint(x: 880, y: 40)
        
        addChild(flyingScoreLabel)
        
        let moveUp = SKAction.moveBy(x: 0, y: 200, duration: 1)
        
        flyingScoreLabel.run(moveUp, completion: {
            flyingScoreLabel.removeFromParent()
        })
    }

    func destroy(Target: SKNode, name: String?) {
        Target.removeFromParent()
        let sizePenality = Target.xScale
        if name == "goodTarget" {
            let calculatedScore = 10 / sizePenality
            score += Int(calculatedScore)
            makeFlyingScore(calculatedScore, increase: true)
        } else if name == "dangerousTarget" {
            let calculatedScore = 10 * sizePenality
            score -= Int(10 * sizePenality)
            makeFlyingScore(calculatedScore, increase: false)
        }
    }
    
    func collision(between bullet: SKNode, object: SKNode) {
        run(sound("bulletImpactGlassShutter.m4a"))
        bullet.removeFromParent()
        if let name = object.name {
            destroy(Target: object, name: name)
        }
    }
    
    func gameOver() {
        let gamOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gamOverLabel.text = "GAME OVER"
        gamOverLabel.fontSize = 80
        gamOverLabel.position = centerPoint
        gamOverLabel.zPosition = 1
        addChild(gamOverLabel)
        run(sound("gameOver.m4a"))
        playAgain()
    }
    
    func playAgain() {
        playAgainLabel = SKLabelNode(fontNamed: "Chalkduster")
        playAgainLabel.text = "play Again!"
        playAgainLabel.fontSize = 50
        playAgainLabel.position = CGPoint(x: 512, y: 230)
        playAgainLabel.zPosition = 1
        addChild(playAgainLabel)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        let names = ["goodTarget", "dangerousTarget"]
        if names.contains(nodeA.name!) && !names.contains(nodeB.name!) {
            collision(between: nodeB, object: nodeA)
        } else if names.contains(nodeB.name!) && !names.contains(nodeA.name!) {
            collision(between: nodeA, object: nodeB)
        }
        
        if isGameOver {
            gameOver()
        }
    }
}
