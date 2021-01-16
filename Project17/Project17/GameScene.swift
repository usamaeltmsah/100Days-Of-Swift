//
//  GameScene.swift
//  Project17
//
//  Created by Usama Fouad on 16/01/2021.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var playAgainLabel: SKLabelNode!
    
    var possipleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: Timer?
    var isGameOver = false
    
    var timer: Double = 1
    var numOfEnemies = 0 {
        didSet {
            if numOfEnemies == 5 {
                timer *= 0.9
                gameTimer?.invalidate()
                gameTimer = Timer.scheduledTimer(timeInterval: timer, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
                numOfEnemies = 0
            }
        }
    }
    
    var isPlayerTouched = false
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    func resetAll() {
        removeAllChildren()
        numOfEnemies = 0
        isGameOver = false
        timer = 1
        gameTimer?.invalidate()
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        resetAll()
        startGame()
    }
    
    func startGame() {
        starfield = SKEmitterNode(fileNamed: "starfield")!
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        
        physicsWorld.gravity = .zero // Or: CGVector(dx: 0, dy: 0)
        // Set current game scene to be the contact delegate of the physics world
        physicsWorld.contactDelegate = self
        
        // timeInterval: 1 -> Means 1 time a second, 0.5 -> -> Means 2 times a second
        gameTimer = Timer.scheduledTimer(timeInterval: timer, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    @objc func createEnemy() {
        if isGameOver { return }
        guard let enemy = possipleEnemies.randomElement() else {
            return
        }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        // Collide with the player
        sprite.physicsBody?.categoryBitMask = 1
        // Speed of moving (From the other side)
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        // Spin while flying
        sprite.physicsBody?.angularVelocity = 5
        // Never slow down.
        sprite.physicsBody?.linearDamping = 0
        // Never stop spinning (constant rate spinning)
        sprite.physicsBody?.angularDamping = 0
        numOfEnemies += 1
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if nodes(at: location).contains(player) {
            isPlayerTouched = true
        }
        
        if isGameOver {
            if nodes(at: location).contains(playAgainLabel) {
                resetAll()
                startGame()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        if isPlayerTouched {
            player.position = location
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isPlayerTouched = false
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        isGameOver = true
        starfield.isPaused = true
        gameOver()
    }
    
    func gameOver() {
        let gamOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gamOverLabel.text = "GAME OVER"
        gamOverLabel.fontSize = 80
        gamOverLabel.position = CGPoint(x: 512, y: 384)
        gamOverLabel.zPosition = 1
        addChild(gamOverLabel)
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
}
