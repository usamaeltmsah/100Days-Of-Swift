//
//  GameScene.swift
//  Project23
//
//  Created by Usama Fouad on 28/01/2021.
//

import AVFoundation
import SpriteKit

enum ForceBomb {
    case never, always, random
}

enum SequenceType: CaseIterable {
    case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain, fastMoving
}

class GameScene: SKScene {
    var gameScore: SKLabelNode!
    
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    var livesImages = [SKSpriteNode]()
    var lives = 3
    
    var isGameOver = false
    var isGameEnded = false
    
    // One for the background, and another for the foreground, to make it glows!
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    
    var activeSlicePoints = [CGPoint]()
    
    var isSwooshingSoundActive = false
    var activeEnemies = [SKSpriteNode]()
    var bombSoundEffect: AVAudioPlayer?
    
    let EnemyType = 1
    let BombType = 0
    let EnemiesTypesRange = 0...6
    let FuseEmitterPositionRelativeToBomb = CGPoint(x: 76, y: 64)
    let RandomPositionXRange = 64...960
    let RandomPositionY = -128
    let RandomAngularVelocityRange: ClosedRange<CGFloat> = -3...3
    let RandomYVelocityRange = 24...32
    let NormalEnemyVelocityScalar = 40
    let FastEnemyVelocityScalar = 50
    let EnemyCircleOfRadius: CGFloat = 64
    let PopTimeScale = 0.991
    let ChainDelayScale = 0.99
    let SpeedScale: CGFloat = 1.02
    let LifeScale: CGFloat = 1.3
    
    var popupTime = 0.9
    var sequence = [SequenceType]()
    var sequencePosition = 0
    var chainDelay = 3.0
    var nextSequenceQueued = true
    
    var gameOverLabel: SKLabelNode!
    
    var playAgainLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        addBackground()
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        physicsWorld.speed = 0.85
        
        createScore()
        createLives()
        createSlices()
        
        sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]
        
        for _ in 0...1000 {
            if let nextSequence = SequenceType.allCases.randomElement() {
                sequence.append(nextSequence)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.toussEnemies()
        }
    }
    
    func addBackground() {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
    }
    
    func createScore() {
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        gameScore.position = CGPoint(x: 8, y: 8)
        score = 0
    }
    
    func createLives() {
        for i in 0 ..< 3 {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: 834 + (i * 70), y: 720)
            addChild(spriteNode)
            livesImages.append(spriteNode)
        }
    }
    
    // Swiping around the screen will lead a glowing trail of slice marks that fade away when you let go or keep on moving.
    func createSlices() {
        // Draw two slice shapes, one in white and one in yellow to make it look like there's a hot glow.
        
        // MARK: SKShapeNode(): Lets you define any kind of shape you can draw, along with line width, stroke color and more, and it will render it to the screen.
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 3
        
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9
        
        activeSliceFG.strokeColor = .white
        activeSliceFG.lineWidth = 5
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        activeSlicePoints.removeAll(keepingCapacity: true)
        
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        
        redrawActiveSlice()
        
        // Remove the fading out actions
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isGameEnded == false else { return }
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !isSwooshingSoundActive {
            playSwooshingSound()
        }
        
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint {
            if node.name == "enemy" || node.name == "fast" {
                // Destroy the benguin
                if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
                    emitter.position = node.position
                    addChild(emitter)
                }
                
                if node.name == "fast" {
                    score += 5
                } else {
                    score += 1
                }
                
                node.name = ""
                node.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                let seq = SKAction.sequence([group, .removeFromParent()])
                node.run(seq)
                
                if let index = activeEnemies.firstIndex(of: node) {
                    activeEnemies.remove(at: index)
                }
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            } else if node.name == "bomb" {
                // Destroy the bomb
                guard let bombContainer = node.parent as? SKSpriteNode else { continue }
                
                if let emitter = SKEmitterNode(fileNamed: "sliceHitBomb") {
                    emitter.position = bombContainer.position
                    addChild(emitter)
                }
                
                node.name = ""
                bombContainer.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                let seq = SKAction.sequence([group, .removeFromParent()])
                bombContainer.run(seq)
                
                if let index = activeEnemies.firstIndex(of: bombContainer) {
                    activeEnemies.remove(at: index)
                }
                run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                endGame(triggeredByBomb: true)
            }
        }
    }
    
    func endGame(triggeredByBomb: Bool) {
        guard isGameEnded == false else { return }
        
        isGameOver = true
        physicsWorld.speed = 0
        isUserInteractionEnabled = false
        
        bombSoundEffect?.stop()
        bombSoundEffect = nil
        
        if triggeredByBomb {
            for i in 0...2 {
                livesImages[i].texture = SKTexture(imageNamed: "sliceLifeGone")
            }
        }
        
        gameOver()
    }
    
    func gameOver() {
        gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 80
        gameOverLabel.position = CGPoint(x: 512, y: 384)
        gameOverLabel.zPosition = 4
        addChild(gameOverLabel)
        playAgain()
    }
    
    func playAgain() {
        playAgainLabel = SKLabelNode(fontNamed: "Chalkduster")
        playAgainLabel.text = "play Again!"
        playAgainLabel.fontSize = 50
        playAgainLabel.position = CGPoint(x: 512, y: 230)
        playAgainLabel.zPosition = 4
        addChild(playAgainLabel)
    }
    
    func playSwooshingSound() {
        isSwooshingSoundActive = true
        let randomNum = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNum).caf"
        
        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        run(swooshSound) { [weak self] in
            self?.isSwooshingSoundActive = false
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    func redrawActiveSlice() {
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            
            return
        }
        
        if activeSlicePoints.count > 12 {
            // Remove first (activeSlicePoints.count - 12) items while drawing.
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
        }
        
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        
        for i in 1 ..< activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
    }
    
    func createEnemy(forceBomb: ForceBomb = .random, isFast: Bool = false) {
        let enemy: SKSpriteNode
        
        var enemyType = Int.random(in: EnemiesTypesRange)
        
        if forceBomb == .never {
            enemyType = EnemyType
        } else if forceBomb == .always {
            enemyType = BombType
        }
        
        if enemyType == BombType {
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            if bombSoundEffect != nil {
                bombSoundEffect?.stop()
                bombSoundEffect = nil
            }
            
            if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
                if let sound = try? AVAudioPlayer(contentsOf: path) {
                    bombSoundEffect = sound
                    sound.play()
                }
            }
            
            if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                emitter.position = FuseEmitterPositionRelativeToBomb
                enemy.addChild(emitter)
            }
        } else {
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemy"
        }
        
        let randomPosition = CGPoint(x: Int.random(in: RandomPositionXRange), y: RandomPositionY)
        enemy.position = randomPosition
        
        let randomAngularVelocity = CGFloat.random(in: RandomAngularVelocityRange)
        let randomXVelocity: Int
        
        if randomPosition.x < 256 {
            randomXVelocity = Int.random(in: 8...15)
        } else if randomPosition.x < 512 {
            randomXVelocity = Int.random(in: 3...5)
        } else if randomPosition.x < 768 {
            randomXVelocity = -Int.random(in: 3...5)
        } else {
            randomXVelocity = -Int.random(in: 8...15)
        }
        
        let randomYVelocity = Int.random(in: RandomYVelocityRange)
        
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: EnemyCircleOfRadius)
        if isFast {
            enemy.name = "fast"
            
            enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * FastEnemyVelocityScalar, dy: randomYVelocity * FastEnemyVelocityScalar)
        } else {
            enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * NormalEnemyVelocityScalar, dy: randomYVelocity * NormalEnemyVelocityScalar)
        }
        
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask = .zero
        
        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    func subtractLife() {
        lives -= 1
        
        run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
        
        var life: SKSpriteNode
        if lives == 2 {
            life = livesImages[0]
        } else if lives == 1 {
            life = livesImages[1]
        } else {
            life = livesImages[2]
            endGame(triggeredByBomb: false)
        }
        
        life.texture = SKTexture(imageNamed: "sliceLifeGone")
        life.xScale = LifeScale
        life.yScale = LifeScale
        life.run(SKAction.scale(to: 1, duration: 0.1))
    }
    
    override func update(_ currentTime: TimeInterval) {
        if activeEnemies.count > 0 {
            for (index, node) in activeEnemies.enumerated().reversed() {
                if node.position.y < -140 {
                    node.removeAllActions()
                    
                    if node.name == "enemy" {
                        node.name = ""
                        subtractLife()
                        
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    } else if node.name == "bombContainer" || node.name == "fast" {
                        node.name = ""
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    }
                }
            }
        } else {
            if !nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [weak self] in
                    self?.toussEnemies()
                }
                
                nextSequenceQueued = true
            }
        }
        
        var bombCount = 0
        
        for node in activeEnemies {
            if node.name == "bombContainer" {
                bombCount += 1
                break
            }
        }
        
        if bombCount == 0 {
            // No bombos - Stop the fuse sound, then destroy it!
            bombSoundEffect?.stop()
            bombSoundEffect = nil
        }
    }
    
    func toussEnemies() {
        guard isGameEnded == false else { return }
        popupTime *= self.PopTimeScale
        chainDelay *= self.ChainDelayScale
        physicsWorld.speed *= self.SpeedScale
        
        let sequenceType = sequence[sequencePosition]
        
        switch sequenceType {
        case .oneNoBomb:
            createEnemy(forceBomb: .never)
        case .one:
            createEnemy()
        case .twoWithOneBomb:
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)
        case .two:
            for _ in 0...1 {
                createEnemy()
            }
        case .three:
            for _ in 0...2 {
                createEnemy()
            }
        case .four:
            for _ in 0...4 {
                createEnemy()
            }
        case .chain:
            createEnemy()
            
            for i in 1...4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * Double(i))) { [weak self] in self?.createEnemy() }
            }
        case .fastChain:
            createEnemy()
            
            for i in 1...4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * Double(i))) { [weak self] in self?.createEnemy() }
            }
        case .fastMoving:
            for _ in 0...Int.random(in: 1...3) {
                createEnemy(forceBomb: .never, isFast: true)
            }
        }
        
        sequencePosition += 1
        nextSequenceQueued = false
    }
}
