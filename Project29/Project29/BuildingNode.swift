//
//  BuildingNode.swift
//  Project29
//
//  Created by Usama Fouad on 09/02/2021.
//

import SpriteKit
import UIKit

// Class for buildings that sets up physics, draws the building graphic, and ultimately handles the building being hit by stray bananas.
class BuildingNode: SKSpriteNode {
    var currentImage: UIImage!
    
    // setup(): will do the basic work required to make this thing a building: setting its name, texture, and physics.
    func setup() {
        name = "building"
        
        currentImage = drawBuilding(size: size)
        texture = SKTexture(image: currentImage)
        
        configurePhysics()
    }
    
    // configurePhysics(): will set up per-pixel physics for the sprite's current texture.
    func configurePhysics() {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = CollisionTypes.building.rawValue
        physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
    }
    
    // drawBuilding(): will do the Core Graphics rendering of a building, and return it as a UIImage.
    func drawBuilding(size: CGSize) -> UIImage {
        // 1. Create a new Core Graphics context the size of our building.
        let renderer = UIGraphicsImageRenderer(size: size)
        
        // 2. Fill it with a rectangle that's one of three colors.
        let img = renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            let color: UIColor
            
            switch Int.random(in: 0...2) {
            // Draw windows all over the building in one of two colors: there's either a light on (yellow) or not (gray).
            case 0:
                // MARK: hue, saturation and brightness, or HSB. Using this method of creating colors you specify values between 0 and 1 to control how saturated a color is (from 0 = gray to 1 = pure color) and brightness (from 0 = black to 1 = maximum brightness), and 0 to 1 for hue.
                
                // MARK: "Hue" is a value from 0 to 1 also, but it represents a position on a color wheel, like using a color picker on your Mac. Hues 0 and 1 both represent red, with all other colors lying in between.
                
                // The helpful thing about HSB is that if you keep the saturation and brightness constant, changing the hue value will cycle through all possible colors – it's an easy way to generate matching pastel colors, for example.
                color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
            case 1:
                color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
            default:
                color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
            }
            
            color.setFill()
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fill)
            
            // 3. Draw windows all over the building in one of two colors: there's either a light on (yellow) or not (gray).
            let lightOnColor = UIColor(hue: 0.19, saturation: 0.67, brightness: 0.99, alpha: 1)
            let lightOffColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)
            
            // count from 10 up to the height of the building minus 10, in intervals of 40. So, it will go 10, 50, 90, 130, and so on
            for row in stride(from: 10, to: Int(size.height - 10), by: 40) {
                for col in stride(from: 10, to: Int(size.width - 10), by: 40) {
                    if Bool.random() {
                        lightOnColor.setFill()
                    } else {
                        lightOffColor.setFill()
                    }
                    
                    ctx.cgContext.fill(CGRect(x: col, y: row, width: 15, height: 20))
                }
            }
        }
        
        // 4. Pull out the result as a UIImage and return it for use elsewhere.
        return img
    }
    
    func hit(at point: CGPoint) {
        // Figure out where the building was hit. Remember: SpriteKit's positions things from the center and Core Graphics from the bottom left!
        let convertedPoint = CGPoint(x: point.x + size.width / 2, y: abs(point.y - (size.height / 2)))
        
        // Create a new Core Graphics context the size of our current sprite.
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            // Draw our current building image into the context. This will be the full building to begin with, but it will change when hit.
            currentImage.draw(at: .zero)
            
            // Create an ellipse at the collision point. The exact co-ordinates will be 32 points up and to the left of the collision, then 64x64 in size - an ellipse centered on the impact point.
            ctx.cgContext.addEllipse(in: CGRect(x: convertedPoint.x - 32, y: convertedPoint.y - 32, width: 64, height: 64))
            
            // Set the blend mode .clear then draw the ellipse, literally cutting an ellipse out of our image.
            
                // .clear, means "delete whatever is there already." When combined with the fact that we already have a property called currentImage you might be able to see how our destructible terrain technique will work!
                // When we want to destroy part of the building, we draw that image into a new context, draw an ellipse using .clear to blast a hole, then save that back to our currentImage property and update our sprite's texture.
            ctx.cgContext.setBlendMode(.clear)
            ctx.cgContext.drawPath(using: .fill)
        }
        // Convert the contents of the Core Graphics context back to a UIImage, which is saved in the currentImage property for next time we’re hit, and used to update our building texture.
        texture = SKTexture(image: img)
        currentImage = img
        
        // Call configurePhysics() again so that SpriteKit will recalculate the per-pixel physics for our damaged building.
        configurePhysics()
    }
}
