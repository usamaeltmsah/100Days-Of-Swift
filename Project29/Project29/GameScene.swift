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
    var buildings = [BuildingNode]()
    
    override func didMove(to view: SKView) {
        // Give the scene a dark blue color to represent the night sky
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        
        createBuildings()
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
}
