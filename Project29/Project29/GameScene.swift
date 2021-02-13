//
//  GameScene.swift
//  Project29
//
//  Created by Usama Fouad on 09/02/2021.
//

import SpriteKit

enum CollisionTypes: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!

    var currentPlayer = 1
    var buildings = [BuildingNode]()
    
    var isGameOver = false
    
    // Because if two objects own each other then we have a strong reference cycle – neither object can be destroyed. The solution is to make one of them have a weak reference to the other: either the game controller owns the game scene strongly, or the game scene owns the game controller strongly, but not both.
    // Solution is straightforward: add a strong reference to the game scene inside the view controller, and add a weak reference to the view controller from the game scene.
    weak var viewController: GameViewController?

    
    override func didMove(to view: SKView) {
        // Give the scene a dark blue color to represent the night sky
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        
        createBuildings()
        createPlayers()
        physicsWorld.contactDelegate = self
    }
    
    func createBuildings() {
        guard !isGameOver else { return }
        // Start at -15 rather than the left edge so that the buildings look like they keep on going past the screen's edge.
        var currentX: CGFloat = -15
        
        // Move horizontally across the screen, filling space with buildings of various sizes until it hits the far edge of the screen.
        while currentX < 1024 {
            // Each building needs to be a random size. For the height, it can be anything between 300 and 600 points high; for the width, make sure it divides evenly into 40 so that our window-drawing code is simple, so we'll generate a random number between 2 and 4 then multiply that by 40 to give us buildings that are 80, 120 or 160 points wide.
            let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))
            // Leave a 2-point gap between the buildings to distinguish their edges slightly more.
            currentX += size.width + 2
            
            let building = BuildingNode(color: .red, size: size)
            building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)
            building.setup()
            addChild(building)
            
            buildings.append(building)
        }
    }
    
    // Texture atlases allows SpriteKit to draw lots of images without having to load and unload textures – it effectively just crops the big image as needed. Xcode automatically generates these atlases for us, even rotating sprites to make them fit more efficiently. And the best bit: just like using Assets.xcassets, you don't need to change your code to make them work; just load sprites the same way you've always done.
    
    func launch(angle: Int, velocity: Int) {
        guard !isGameOver else { return }
        // 1. Figure out how hard to throw the banana. We accept a velocity parameter.
        let speed = Double(velocity) / 10.0
        // 2. Convert the input angle to radians. Most people don't think in radians, so the input will come in as degrees that we will convert to radians.
        let radians = deg2Rad(degrees: angle)
        // 3. If somehow there's a banana already, we'll remove it then create a new one using circle physics.
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody?.categoryBitMask = CollisionTypes.banana.rawValue
        banana.physicsBody?.collisionBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody?.contactTestBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        
        // Enable the usesPreciseCollisionDetection property for the banana's physics body. This works slower, but it's fine for occasional use.
        banana.physicsBody?.usesPreciseCollisionDetection = true
        addChild(banana)
        
        // 4. If player 1 was throwing the banana, we position it up and to the left of the player and give it some spin.
        if currentPlayer == 1 {
            banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            banana.physicsBody?.angularVelocity = -20
            // 5. Animate player 1 throwing their arm up then putting it down again.
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player1.run(sequence)
            // 6. Make the banana move in the correct direction.
            // To make the banana actually move, we use the applyImpulse() method of its physics body, which accepts a CGVector as its only parameter and gives it a physical push in that direction.
            // If we calculate the cosine of our angle in radians it will tell us how much horizontal momentum to apply, and if we calculate the sine of our angle in radians it will tell us how much vertical momentum to apply.
            let impulse  = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        } else {
            // 7. If player 2 was throwing the banana, we position it up and to the right, apply the opposite spin, then make it move in the correct direction.
            banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
            banana.physicsBody?.angularVelocity = 20

            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player2.run(sequence)

            let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        }
    }
    
    func createPlayers() {
        guard !isGameOver else { return }
        // 1. Create a player sprite and name it "player1".
        player1 = SKSpriteNode(imageNamed: "player")
        player1.name = "player1"
        // 2. Create a physics body for the player that collides with bananas, and set it to not be dynamic.
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
        player1.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player1.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody?.isDynamic = false
        // 3. Position the player at the top of the second building in the array. (This is why we needed to keep an array of the buildings.)
        let player1Building = buildings[1]
        player1.position = CGPoint(x: player1Building.position.x, y: player1Building.position.y + ((player1Building.size.height + player1.size.height) / 2))
        // 4. Add the player to the scene.
        addChild(player1)
        // 5. Repeat all the above for player 2, except they should be on the second to last building.
        player2 = SKSpriteNode(imageNamed: "player")
            player2.name = "player2"
            player2.physicsBody = SKPhysicsBody(circleOfRadius: player2.size.width / 2)
            player2.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
            player2.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
            player2.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
            player2.physicsBody?.isDynamic = false

            let player2Building = buildings[buildings.count - 2]
            player2.position = CGPoint(x: player2Building.position.x, y: player2Building.position.y + ((player2Building.size.height + player2.size.height) / 2))
            addChild(player2)
    }
    
    func deg2Rad(degrees: Int) -> Double {
        return Double(degrees) * Double.pi / 180
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard !isGameOver else { return }
        // we need to consider: banana hit building, building hit banana (remember the philosophy?), banana hit player1, player1 hit banana, banana hit player2 and player2 hit banana.
        // This is a lot to check, so we're going to eliminate half of them by eliminating whether "banana hit building" or "building hit banana".
        
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        guard let firstNode = firstBody.node else { return }
        guard let secondNode = secondBody.node else { return }
        
        //  If we get banana (collision type 1) and building (collision type 2) we'll put banana in body 1 and building in body 2, but if we get building (2) and banana (1) then we'll still put banana in body 1 and building in body 2.
        if firstNode.name == "banana" && secondNode.name == "building" {
            bananaHit(building: secondNode, atPoint: contact.contactPoint)
        }
        
        if firstNode.name == "banana" && secondNode.name == "player1" {
            destroy(player: player1)
        }
        
        if firstNode.name == "banana" && secondNode.name == "player2" {
            destroy(player: player2)
        }
    }
    
    func destroy(player: SKSpriteNode) {
        if let explosion = SKEmitterNode(fileNamed: "hitPlayer") {
            explosion.position = player.position
            addChild(explosion)
        }
        
        player.removeFromParent()
        banana.removeFromParent()
        
        if player.name == "player1" {
            viewController?.player2Score += 1
        } else {
            viewController?.player1Score += 1
        }
        
        if viewController!.player1Score >= 3 {
            endGame(winner: 1)
            return
        } else if viewController!.player2Score >= 3 {
            endGame(winner: 2)
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // To transition from one scene to another,
            // 1.you first create the scene.
            let newGame = GameScene(size: self.size)
            newGame.viewController = self.viewController
            self.viewController?.currentGame = newGame
            
            self.changePlayer()
            newGame.currentPlayer = self.currentPlayer
            
            // 2. Create a transition using the list available from SKTransition.
            let transition = SKTransition.doorway(withDuration: 0.5)
            // Finally use the presentScene() method of our scene's view, passing in the new scene and the transition you created.
            self.view?.presentScene(newGame, transition: transition)
        }
    }
    
    func changePlayer() {
        guard !isGameOver else { return }
        if currentPlayer == 1 {
            currentPlayer = 2
        } else {
            currentPlayer = 1
        }
        
        viewController?.activatePlayer(number: currentPlayer)
    }
    
    func bananaHit(building: SKNode, atPoint contactPoint: CGPoint) {
        guard let building = building as? BuildingNode else { return }
        let buildingLocation = convert(contactPoint, to: building)
        building.hit(at: buildingLocation)
        
        if let explosion = SKEmitterNode(fileNamed: "hitBuilding") {
            explosion.position = contactPoint
            addChild(explosion)
        }
        
        // Use banana.name = "", to fix a small but annoying bug: if a banana just so happens to hit two buildings at the same time, then it will explode twice and thus call changePlayer() twice – effectively giving the player another throw. By clearing the banana's name here, the second collision won't happen because our didBegin() method won't see the banana as being a banana any more – its name is gone.
        banana.name = ""
        banana.removeFromParent()
        banana = nil
        
        changePlayer()
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard banana != nil else { return }
        
        if abs(banana.position.y) > 1000 {
            banana.removeFromParent()
            banana = nil
            changePlayer()
        }
    }
    
    func endGame(winner: Int) {
        isGameOver = true
        
        displayWinner(winner: winner)
    }
    
    func displayWinner(winner: Int) {
        let text = "Player \(winner) is the WINNER"
        let attributedString = NSMutableAttributedString(string: text)
        
        attributedString.addAttributes([.foregroundColor: UIColor.white, .font: UIFont(name: "Chalkduster", size: 70)!, .strokeWidth: 5, .strokeColor: UIColor.red], range: NSRange(location: 0, length: 8))
        attributedString.addAttributes([.foregroundColor: UIColor.white, .font: UIFont(name: "Chalkduster", size: 50)!, .strokeWidth: 3, .strokeColor: UIColor.black], range: NSRange(location: 8, length: text.count - 8))
        let winnerLabel = SKLabelNode(attributedText: attributedString)
        winnerLabel.zPosition = .infinity
        winnerLabel.position = CGPoint(x: 512, y: 365)
        addChild(winnerLabel)
    }
}
