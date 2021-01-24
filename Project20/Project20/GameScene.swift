//
//  GameScene.swift
//  Project20
//
//  Created by Usama Fouad on 23/01/2021.
//

import SpriteKit

class GameScene: SKScene {
    var gameTimer: Timer?
    var fireWorks = [SKNode]()
    
    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22
    
    var scoreLabel: SKLabelNode!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var numLaunches = 5 {
        didSet {
            leftLaunchesLabel.text = "Left launches: \(numLaunches)"
        }
    }
    
    var isGameOver = false
    
    var gameOverLabel: SKLabelNode!
    
    var playAgainLabel: SKLabelNode!
    
    var leftLaunchesLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        play()
    }
    
    func addViews() {
        addBackground()
        addScoreLabel()
        addLeftLaunchesLabel()
    }
    
    func resetAll() {
        addViews()
        numLaunches = 5
        isGameOver = false
        score = 0
        gameTimer?.invalidate()
    }
    
    func play() {
        removeAllActions()
        removeAllChildren()
        
        resetAll()
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
    
    func addBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
    }
    
    func addScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 900, y: 730)
        score = 0
        scoreLabel.text = "Score: \(score)"
        addChild(scoreLabel)
    }
    
    func addLeftLaunchesLabel() {
        leftLaunchesLabel = SKLabelNode(fontNamed: "Chalkduster")
        leftLaunchesLabel.position = CGPoint(x: 150, y: 50)

        leftLaunchesLabel.text = "Left launches: \(numLaunches)"
        addChild(leftLaunchesLabel)
    }
    
    // xMovement: speed of the firework, X and Y positions for creation.
    func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        // 1. Create an SKNode that will act as the firework container, and place it at the position that was specified.
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        // 2. Create a rocket sprite node, give it the name "firework" so we know that it's the important thing, adjust its colorBlendFactor property so that we can color it, then add it to the container node.
        let firework = SKSpriteNode(imageNamed: "rocket")
        
        // colorBlendFactor: ability to recolor your sprites dynamically with absolutely no performance cost.
        // with colorBlendFactor set to 1 (use the new color exclusively)
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)
        
        // 3. Give the firework sprite node one of three random colors: cyan, green or red. I've chosen cyan because pure blue isn't particularly visible on a starry sky background picture.
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .cyan
        case 1:
            firework.color = .green
        case 2:
            firework.color = .red
        default:
            break
        }
        
        // 4. Create a UIBezierPath that will represent the movement of the firework.
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        // 5. Tell the container node to follow that path, turning itself as needed.
        // follow(): takes a CGPath as its first parameter (we'll pull this from the UIBezierPath) and makes the node move along that path.
        // asOffset: decides whether the path coordinates are absolute or are relative to the node's current position. If you specify it as true, it means any coordinates in your path are adjusted to take into account the node's position.
        // orientToPath: When it's set to true, the node will automatically rotate itself as it moves on the path so that it's always facing down the path.
        // speed: how fast it moves along the path.
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(move)
        
        // 6. Create particles behind the rocket to make it look like the fireworks are lit.
        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 0, y: -22)
            node.addChild(emitter)
        }
        
        // 7. Add the firework to our fireworks array and also to the scene.
        fireWorks.append(node)
        addChild(node)
    }
    
    @objc func launchFireworks() {
        if numLaunches <= 0 {
            isGameOver = true
            return
        }
        let movementAmount: CGFloat = 1800
        
        switch Int.random(in: 0...3) {
        case 0:
            // Fire five, straight up
            for i in -2...2 {
                createFirework(xMovement: 0, x: 512 + i*100, y: bottomEdge)
            }
        case 1:
            // Fire five, in a fan
            for i in -2...2 {
                createFirework(xMovement: CGFloat(i*100), x: 512 + i*100, y: bottomEdge)
            }
        case 2:
            // Fire five, from the left to the right
            for i in 0...4 {
                createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + i*100)
            }
        case 3:
            // Fire five, from the right to the left
            for i in 0...4 {
                createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + i*100)
            }
        default:
            break
        }
        numLaunches -= 1
    }
    
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint {
            guard node.name == "firework" else { continue }
            
            // The loop will go through every firework in our fireworks array, then find the firework image inside it. If the firework was selected and is a different color to the firework that was just tapped, then we'll put its name back to "firework" and put its colorBlendFactor back to 1 so it resumes its old color.
            
            for parent in fireWorks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue }
                
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            
            node.name = "selected"
            node.colorBlendFactor = 0
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if isGameOver {
            if nodes(at: location).contains(playAgainLabel) {
                play()
                return
            }
        }
        
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isGameOver {
            gameTimer?.invalidate()
            gameOver()
        }
        
        for (index, firework) in fireWorks.enumerated().reversed() {
            if firework.position.y > 900 {
                // This uses a position high above so that rockets can explode off screen
                fireWorks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    func explode(firework: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitter.position = firework.position
            addChild(emitter)
            
            let wait = SKAction.wait(forDuration: 2)
            let remove = SKAction.removeFromParent()
            
            let sequence = SKAction.sequence([wait, remove])
            
            emitter.run(sequence)
        }
        
        firework.removeFromParent()
    }
    
    func explodeFireworks() {
        var numExploded = 0
        
        for (index, fireworkContainer) in fireWorks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }
            
            if firework.name == "selected" {
                // destroy this firework!
                explode(firework: fireworkContainer)
                fireWorks.remove(at: index)
                numExploded += 1
            }
        }
        
        switch numExploded {
        case 0:
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }
    
    func gameOver() {
        gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 80
        gameOverLabel.position = CGPoint(x: 512, y: 384)
        gameOverLabel.zPosition = 1
        addChild(gameOverLabel)
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
