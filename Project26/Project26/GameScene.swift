//
//  GameScene.swift
//  Project26
//
//  Created by Usama Fouad on 02/02/2021.
//

import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        
    }
    
    func loadLevel() {
        guard let levelURL = Bundle.main.url(forResource: "level1", withExtension: "txt") else {
            fatalError("Couldn't find level1.txt in the app bundle.")
        }
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Couldn't load level1.txt from the app bundle.")
        }
        
        let lines = levelString.split(separator: "\n")
        
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
                
                if letter == "x" {
                    // Load wall
                } else if letter == "v" {
                    // Load vortex
                } else if letter == "s" {
                    // Load star
                } else if letter == "f" {
                    // Load finish point
                } else {
                    fatalError("Unkown level letter \(letter)")
                }
            }
        }
    }
}
