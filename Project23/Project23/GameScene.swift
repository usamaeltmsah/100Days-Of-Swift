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

// CaseIterable: It's one of Swift’s most useful protocols, and it will automatically add an "allCases" property to the SequenceType enum that lists all its cases as an array. This is really useful in our project because we can then use randomElement() to pick random sequence types to run our game.
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
    
    // popupTime: The amount of time to wait between the last enemy being destroyed and a new one being created.
    var popupTime = 0.9
    // sequence: Array of our SequenceType enum that defines what enemies to create.
    var sequence = [SequenceType]()
    // sequencePosition: Is where we are right now in the game.
    var sequencePosition = 0
    // chainDelay: How long to wait before creating a new enemy when the sequence type is .chain or .fastChain. Enemy chains don't wait until the previous enemy is offscreen before creating a new one, so it's like throwing five enemies quickly but with a small delay between each one.
    var chainDelay = 3.0
    // nextSequenceQueued: Used so we know when all the enemies are destroyed and we're ready to create more.
    var nextSequenceQueued = true
    
    var gameOverLabel: SKLabelNode!
    
    var playAgainLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        play()
    }
    
    func resetAll() {
        removeAllActions()
        removeAllChildren()
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        physicsWorld.speed = 0.85
        
        lives = 3
        popupTime = 0.9
        sequencePosition = 0
        chainDelay = 3.0
        
        isGameEnded = false
        isSwooshingSoundActive = false
        nextSequenceQueued = true
        
        livesImages.removeAll()
        activeSlicePoints.removeAll()
        activeEnemies.removeAll()
        
        addViews()
    }
    
    func addViews() {
        addBackground()
        createScore()
        createLives()
        createSlices()
    }
    
    func play() {
        resetAll()
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
        
        // 1. Remove all existing points in the activeSlicePoints array, because we're starting fresh.
        activeSlicePoints.removeAll(keepingCapacity: true)
        
        let location = touch.location(in: self)
        
        if isGameEnded {
            if nodes(at: location).contains(playAgainLabel) {
                play()
            }
        }
        
        // 2. Get the touch location and add it to the activeSlicePoints array.
        activeSlicePoints.append(location)
        
        // 3.Clear the slice shapes.
        redrawActiveSlice()
        
        // 4. Remove any actions that are currently attached to the slice shapes. This will be important if they are in the middle of a fadeOut(withDuration:) action.
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        
        // Set both slice shapes to have an alpha value of 1 so they are fully visible (Cause as it fading out it will be 0 at the end!).
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
                
                // Create a particle effect over the penguin.
                if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
                    emitter.position = node.position
                    addChild(emitter)
                }
                
                if node.name == "fast" {
                    // Add 5 to the player's score if player touches a fast penguin.
                    score += 5
                } else {
                    // Add 1 to the player's score if player touches a normal penguin.
                    score += 1
                }
                
                // Clear its node name so that it can't be swiped repeatedly.
                node.name = ""
                // Disable the isDynamic of its physics body so that it doesn't carry on falling.
                node.physicsBody?.isDynamic = false
                
                // Make the penguin scale out and fade out at the same time.
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                // An action 'group' specifies that all actions inside it should execute simultaneously,
                // whereas an action 'sequence' runs them all one at a time.
                let group = SKAction.group([scaleOut, fadeOut])
                // .removeFromParent(): After making the penguin scale out and fade out, we should remove it from the scene.
                let seq = SKAction.sequence([group, .removeFromParent()])
                node.run(seq)
                
                // Remove the enemy from our activeEnemies array.
                if let index = activeEnemies.firstIndex(of: node) {
                    activeEnemies.remove(at: index)
                }
                // Play a sound so the player knows they hit the penguin.
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
        
        isGameEnded = true
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
        isUserInteractionEnabled = true
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
        // When the player first swipes we set isSwooshSoundActive to be true, and only when the swoosh sound has finished playing do we set it back to false again. This will allow us to ensure only one swoosh sound is playing at a time.
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
        // 1. If we have fewer than two points in our array, we don't have enough data to draw a line so it needs to clear the shapes and exit the method.
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            
            return
        }
        
        // 2. If we have more than 12 slice points in our array, we need to remove the oldest ones until we have at most 12 – this stops the swipe shapes from becoming too long.
        if activeSlicePoints.count > 12 {
            // Remove first (activeSlicePoints.count - 12) items while drawing.
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
        }
        
        // 3. It needs to start its line at the position of the first swipe point, then go through each of the others drawing lines to each point.
        // SKShapeNode's path: describes the shape we want to draw. When it's nil, there's nothing to draw; when it's set to a valid path, that gets drawn with the SKShapeNode's settings.
        let path = UIBezierPath()
        
        // Position the start of our lines.
        path.move(to: activeSlicePoints[0])
        
        // Loop through our activeSlicePoints array and call the path's addLine(to:) method for each point.
        for i in 1 ..< activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        // 4. Finally, it needs to update the slice shape paths so they get drawn using their designs – i.e., line width and color.
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
            // 1. Create a new SKSpriteNode that will hold the fuse and the bomb image as children, setting its Z position to be 1.
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            // 2. Create the bomb image, name it "bomb", and add it to the container.
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            // 3. If the bomb fuse sound effect is playing, stop it and destroy it.
            if bombSoundEffect != nil {
                bombSoundEffect?.stop()
                bombSoundEffect = nil
            }
            
            // 4. Create a new bomb fuse sound effect, then play it.
            if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
                if let sound = try? AVAudioPlayer(contentsOf: path) {
                    bombSoundEffect = sound
                    sound.play()
                }
            }
            
            // 5. Create a particle emitter node, position it so that it's at the end of the bomb image's fuse, and add it to the container.
            if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                emitter.position = FuseEmitterPositionRelativeToBomb
                enemy.addChild(emitter)
            }
        } else {
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemy"
        }
        
        // 1. Give the enemy a random position off the bottom edge of the screen.
        let randomPosition = CGPoint(x: Int.random(in: RandomPositionXRange), y: RandomPositionY)
        enemy.position = randomPosition
        
        // 2. Create a random angular velocity, which is how fast something should spin.
        let randomAngularVelocity = CGFloat.random(in: RandomAngularVelocityRange)
        
        // 3. Create a random X velocity (how far to move horizontally) that takes into account the enemy's position.
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
        
        // 4. Create a random Y velocity just to make things fly at different speeds.
        let randomYVelocity = Int.random(in: RandomYVelocityRange)
        
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: EnemyCircleOfRadius)
        if isFast {
            enemy.name = "fast"
            
            enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * FastEnemyVelocityScalar, dy: randomYVelocity * FastEnemyVelocityScalar)
        } else {
            enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * NormalEnemyVelocityScalar, dy: randomYVelocity * NormalEnemyVelocityScalar)
        }
        
        // 5. Give all enemies a circular physics body where the collisionBitMask is set to 0 so they don't collide.
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
    
    // This method is called every frame before it's drawn, and gives you a chance to update your game state as you want.
    override func update(_ currentTime: TimeInterval) {
        
        // If we have active enemies, we loop through each of them.
        if activeEnemies.count > 0 {
            for (index, node) in activeEnemies.enumerated().reversed() {
                // If any enemy is at or lower than Y position -140, we remove it from the game and our activeEnemies array.
                if node.position.y < -140 {
                    node.removeAllActions()
                    // If you miss a penguin you lose one life; else if you swipe a bomb, you lose all your lives.
                    if node.name == "enemy" {
                        node.name = ""
                        // If the player misses slicing a normal speed penguin, they lose a life
                        subtractLife()
                        
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    } else if node.name == "bombContainer" || node.name == "fast" {
                        // Delete the node's name just in case any further checks for enemies or bombs happen – clearing the node name will avoid any problems.
                        node.name = ""
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    }
                }
            }
        } else {
            // If we don't have any active enemies and we haven't already queued the next enemy sequence, we schedule the next enemy sequence and set nextSequenceQueued to be true.
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
            
            // To handle these chains, we have calls to asyncAfter() with a timer value. If we assume for a moment that chainDelay is 10 seconds, then:
            
                // That makes chainDelay / 10.0 equal to 1 second.
                // That makes chainDelay / 10.0 * 2 equal to 2 seconds.
                // That makes chainDelay / 10.0 * 3 equal to three seconds.
                // That makes chainDelay / 10.0 * 4 equal to four seconds.
            for i in 1...4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * Double(i))) { [weak self] in self?.createEnemy() }
            }
        case .fastMoving:
            for _ in 0...Int.random(in: 1...3) {
                createEnemy(forceBomb: .never, isFast: true)
            }
        }
        
        sequencePosition += 1
        // nextSequenceQueued: If it's false, it means we don't have a call to tossEnemies() in the pipeline waiting to execute. It gets set to true only in the gap between the previous sequence item finishing and tossEnemies() being called. Think of it as meaning, "I know there aren't any enemies right now, but more will come shortly."
        nextSequenceQueued = false
    }
}
