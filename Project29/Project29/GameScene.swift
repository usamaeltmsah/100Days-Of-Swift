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

class GameScene: SKScene {
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!

    var currentPlayer = 1
    var buildings = [BuildingNode]()
    
    // Because if two objects own each other then we have a strong reference cycle – neither object can be destroyed. The solution is to make one of them have a weak reference to the other: either the game controller owns the game scene strongly, or the game scene owns the game controller strongly, but not both.
    // Solution is straightforward: add a strong reference to the game scene inside the view controller, and add a weak reference to the view controller from the game scene.
    weak var viewController: GameViewController?

    
    override func didMove(to view: SKView) {
        // Give the scene a dark blue color to represent the night sky
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        
        createBuildings()
        createPlayers()
    }
    
    func createBuildings() {
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
        
    }
    
    func createPlayers() {
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
}
