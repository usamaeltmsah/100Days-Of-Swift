//
//  GameScene.swift
//  Project26
//
//  Created by Usama Fouad on 02/02/2021.
//

import CoreMotion
import SpriteKit

enum CollisionTypes: UInt32 {
    // MARK: Bitmasks should start at 1 then double each time.
    case player = 1
    case wall = 2
    case star = 4
    case vortes = 8
    case finish = 16
    case teleport = 32
}
class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: SKSpriteNode!
    var lastTouchPosition: CGPoint?
    var motionManager: CMMotionManager!
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var isGameOver = false
    
    var levelLabel: SKLabelNode!
    var currentLevel = 1 {
        didSet {
            levelLabel.text = "Level: \(currentLevel)"
        }
    }
    
    var teleports = [SKNode]()
    
    var isMoved: Bool!
    
    let startPoint = CGPoint(x: 96, y: 672)
    
    override func didMove(to view: SKView) {
        addBackground()
        
        physicsWorld.gravity = .zero
        // Make ourselves the contact delegate for the physics world
        physicsWorld.contactDelegate = self
        
        loadLevel(levelNum: currentLevel)
        createPlayer(at: startPoint)
        addScore()
        addLevel()
        
        isMoved = false
        
        // MARK: All motion detection is done with an Apple framework called Core Motion, and most of the work is done by a class called CMMotionManager. Using it here won't require any special user permissions, so all we need to do is create an instance of the class and ask it to start collecting information.
        // MARK: Accelerometer data is only available after we have called startAccelerometerUpdates() on our motion manager.
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
    }
    
    func addBackground() {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        
        addChild(background)
    }
    
    func addScore() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
    }
    
    func addLevel() {
        levelLabel = SKLabelNode(fontNamed: "Chalkduster")
        levelLabel.text = "Level: \(currentLevel)"
        levelLabel.horizontalAlignmentMode = .center
        levelLabel.position = CGPoint(x: 512, y: 725)
        levelLabel.fontSize = 50
        levelLabel.zPosition = 1
        addChild(levelLabel)
    }
    
    func loadLevel(levelNum: Int) {
        guard let levelURL = Bundle.main.url(forResource: "level\(levelNum)", withExtension: "txt") else {
            fatalError("Couldn't find level1.txt in the app bundle.")
        }
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Couldn't load level1.txt from the app bundle.")
        }
        
        teleports.removeAll()
        
        let lines = levelString.split(separator: "\n")
        
        //  enumerated() method: loops over an array, extracting each item and its position in the array.
        // for SpriteKit Y:0 is the bottom of the screen whereas for UIKit Y:0 is the top. When it comes to loading level rows, this means we need to read them in reverse so that the last row is created at the bottom of the screen and so on upwards.
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
                
                if letter == "x" {
                    loadWall(at: position)
                } else if letter == "v" {
                    loadVortex(at: position)
                } else if letter == "s" {
                    loadStar(at: position)
                } else if letter == "f" {
                    loadFinishPoint(at: position)
                } else if letter == "t" {
                    loadTeleport(at: position)
                } else if letter == " " {
                    // This is empty space do nothing
                } else {
                    fatalError("Unkown level letter \(letter)")
                }
            }
        }
    }
    
    func loadWall(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "block")
        node.position = position
        
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        node.physicsBody?.isDynamic = false
        
        addChild(node)
    }
    
    func loadVortex(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "vortex")
        node.name = "vortex"
        node.position = position
        node.run(SKAction.rotate(byAngle: .pi, duration: 1))
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        // MARK: “category” defines what something is, “collision” defines what it should be bounce off, and “contact” defines what collisions you want to be informed on.
        
        // MARK: categoryBitMask: determines what type of thing this physics body is.
        node.physicsBody?.categoryBitMask = CollisionTypes.vortes.rawValue
        
        // MARK: contactTestBitMask: is a number defining which collisions we want to be notified about.
        //  sets the contactTestBitMask property to the value of the player's category, which means we want to be notified when these two touch.
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        
        // MARK: collisionBitMask: determines which other objects it bounces off.
        node.physicsBody?.collisionBitMask = 0
        
        // MARK: Category: every node you want to reference in your collision bitmasks or your contact test bitmasks must have a category attached. If you give a node a collision bitmask but not a contact test bitmask, it means they will bounce off each other but you won't be notified. If you do the opposite (contact test but not collision) it means they won't bounce off each other but you will be told when they overlap.
        
        // MARK: By default, physics bodies have a collision bitmask that means "everything", so everything bounces off everything else. By default, they also have a contact test bitmask that means "nothing", so you'll never get told about collisions.
        
        addChild(node)
    }
    
    func loadStar(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "star")
        node.name = "star"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        
        addChild(node)
    }
    
    func loadTeleport(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "teleport")
        node.name = "teleport"
        node.size = CGSize(width: node.size.width / 4, height: node.size.height / 4)
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 4)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.teleport.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        
        addChild(node)
        teleports.append(node)
    }
    
    func loadFinishPoint(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "finish")
        node.name = "finish"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        
        addChild(node)
    }
    
    func createPlayer(at position: CGPoint) {
        player = SKSpriteNode(imageNamed: "player")
        player.position = position
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        // MARK: linearDamping property of a physics body lets us control how much friction applies to it.
        player.physicsBody?.linearDamping = 0.5
        
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        
        addChild(player)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameOver == false else { return }

        #if targetEnvironment(simulator)
            if let currentTouch = lastTouchPosition {
                // Calculate the difference between the current touch and the player's position, then use that to change the gravity value of the physics world.
                let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
                physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
            }
        #else
            // The code to read from the accelerometer and apply its tilt data to the world gravity:
        
            // Safely unwraps the optional accelerometer data, because there might not be any available.
            if let accelerometerData = motionManager.accelerometerData {
                // Change the gravity of our game world so that it reflects the accelerometer data.
                // Passing accelerometer Y to CGVector's X and accelerometer X to CGVector's Y. Remember, your device is rotated to landscape right now, which means you also need to flip your coordinates around.
                physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * -50)
            }
        #endif
        isMoved = true
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // There are three types of collision we care about: when the player hits a vortex they should be penalized, when the player hits a star they should score a point, and when the player hits the finish flag the next level should be loaded.
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            playerCollide(with: nodeB)
        } else if nodeB == player {
            playerCollide(with: nodeA)
        }
    }
    
    func playerCollide(with node: SKNode) {
        // Things need to be done when a player collides with a vortex:
        if node.name == "vortex" {
            // 1. We need to stop the ball from being a dynamic physics body so that it stops moving once it's sucked in.
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1
            
            // We need to move the ball over the vortex, to simulate it being sucked in. It will also be scaled down at the same time.
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            
            // Once the move and scale has completed, we need to remove the ball from the game.
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            
            player.run(sequence) { [weak self] in
                // After all the actions complete, we need to create the player ball again and re-enable control.
                self?.createPlayer(at: self!.startPoint)
                self?.isGameOver = false
            }
        } else if node.name == "teleport" && isMoved {
            player.physicsBody?.isDynamic = false
            
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            
            player.run(sequence) { [weak self] in
                // After all the actions complete, we need to create the player ball again and re-enable control.
                if let index = self?.teleports.firstIndex(of: node) {
                    self?.exitTeleport(for: index)
                }
            }
        } else if node.name == "star" {
            node.removeFromParent()
            score += 1
        } else if node.name == "finish" {
            // next level?
            player.physicsBody?.isDynamic = false
            removeAllChildren()
            showLevelUp()
            addBackground()
            currentLevel += 1
            loadLevel(levelNum: currentLevel)
            addScore()
            addLevel()
            createPlayer(at: startPoint)
        }
    }
    
    func exitTeleport(for index: Int) {
        if teleports.count > 1 {
            if teleports[index] == teleports.first {
                createPlayer(at: teleports[1].position)
            } else {
                createPlayer(at: teleports[index - 1].position)
            }
            isMoved = false
        }
    }
    
    func showLevelUp() {
        let levelUpLabel = SKLabelNode(fontNamed: "Chalkduster")
        levelUpLabel.text = "Level Up 🔝🔥"
        levelUpLabel.horizontalAlignmentMode = .center
        levelUpLabel.position = CGPoint(x: 512, y: 342)
        levelUpLabel.fontSize = 100
        levelUpLabel.zPosition = 1
        addChild(levelUpLabel)
        
        levelUpLabel.run(SKAction.fadeOut(withDuration: 3)) {
            levelUpLabel.removeFromParent()
        }
    }
}
