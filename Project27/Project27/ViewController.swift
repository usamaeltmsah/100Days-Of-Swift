//
//  ViewController.swift
//  Project27
//
//  Created by Usama Fouad on 03/02/2021.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    var currentDrawType = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        drawRectangle()
    }

    @IBAction func redrawTapped(_ sender: Any) {
        currentDrawType += 1
        
        if currentDrawType > 7 {
            currentDrawType = 0
        }
        
        switch currentDrawType {
        case 0:
            drawRectangle()
        case 1:
            drawCircle()
        case 2:
            drawCheckerboard()
        case 3:
            drawRotetedSquares()
        case 4:
            drawLines()
        case 5:
            drawImgesAndText()
        case 6:
            drawEmoji()
        case 7:
            spellTWIN()
        default:
            break
        }
    }
    
    func drawRectangle() {
        // renderer object: used tp render context, but everything between will be Core Graphics functions or UIKit methods that are designed to work with Core Graphics contexts.
        // In Core Graphics, a context is a canvas upon which we can draw, but it also stores information about how we want to draw (e.g., what should our line thickness be?) and information about the device we are drawing to. So, it's a combination of canvas and metadata all in one, and it's what you'll be using for all your drawing. This Core Graphics context is exposed to us when we render with UIGraphicsImageRenderer.
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        // To kick off rendering you can either call the image() function to get back a UIImage of the results, or call the pngData() and jpegData() methods to get back a Data object in PNG or JPEG format respectively.
        // It gets passed a single parameter that named ctx, which is a reference to a UIGraphicsImageRendererContext to draw to. This is a thin wrapper around another data type called CGContext, which is where the majority of drawing code lives.
        let image = renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 15, dy: 15)
            
            // almost all the good stuff lies in its "cgContext" property that gives us the full power of Core Graphics.
            
            // setFillColor(): sets the fill color of our context, which is the color used on the insides of the rectangle we'll draw.
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            // setStrokeColor(): sets the stroke color of our context, which is the color used on the line around the edge of the rectangle we'll draw.
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            // setLineWidth(): adjusts the line width that will be used to stroke our rectangle. Note that the line is drawn centered on the edge of the rectangle, so a value of 10 will draw 5 points inside the rectangle and five points outside.
            ctx.cgContext.setLineWidth(10)
            
            // You can add multiple paths to your context before drawing, which means Core Graphics batches them all together.
            
            // addRect(): adds a CGRect rectangle to the context's current path to be drawn.
            ctx.cgContext.addRect(rectangle)
            // drawPath(): draws the context's current path using the state you have configured.
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        imageView.image = image
    }
    
    func drawCheckerboard() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { ctx in
            ctx.cgContext.setFillColor( UIColor.black.cgColor)
            
            for row in 0 ..< 8 {
                for col in 0 ..< 8 {
                    if (row + col).isMultiple(of: 2) {
                        // fill(): skips the add path / draw path work and just fills the rectangle given as its parameter using whatever the current fill color is.
                        ctx.cgContext.fill(CGRect(x: col * 64, y: row * 64, width: 64, height: 64))
                    }
                }
            }
        }
        imageView.image = image
        
        // We're filling every other square in black, but leaving the other squares alone. As we haven’t specified that our renderer is opaque, this means those places where we haven't filled anything will be transparent. So, if the view behind was green, you'd get a black and green checkerboard.
        // You can make checkerboards using a Core Image filter – check out CICheckerboardGenerator to see how!
    }
    
    func drawRotetedSquares() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { ctx in
            // translateBy(): translates (moves) the current transformation matrix.
            ctx.cgContext.translateBy(x: 256, y: 256)
            
            let rotations = 40
            let amount = Double.pi / Double(rotations)
            
            for _ in 0 ..< rotations {
                // rotate(by:): rotates the current transformation matrix.
                // Modifying the CTM(current transformation matrix) is cumulative, which is what makes the above code work. That is, when you rotate the CTM, that transformation is applied on top of what was there already, rather than to a clean slate. So the code works by rotating the CTM a small amount more every time the loop goes around.
                ctx.cgContext.rotate(by: CGFloat(amount))
                // The current transformation matrix is very similar to those CGAffineTransform modifications we used in project 15, except its application is a little different in Core Graphics. In UIKit, you rotate drawing around the center of your view, as if a pin was stuck right through the middle. In Core Graphics, you rotate around the top-left corner, so to avoid that we're going to move the transformation matrix half way into our image first so that we've effectively moved the rotation point.
                // This also means we need to draw our rotated squares so they are centered on our center: for example, setting their top and left coordinates to be -128 and their width and height to be 256.
                ctx.cgContext.addRect(CGRect(x: -128, y: -128, width: 256, height: 256))
            }
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            // strokePath(): strokes the path with your specified line width, which is 1 if you don't set it explicitly.
            ctx.cgContext.strokePath()
        }
        imageView.image = image
    }
    
    func drawCircle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { ctx in
            // insetBy(dx: 15, dy: 15): adds 15 points of inset on each edge
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 15, dy: 15)
            
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        imageView.image = image
    }
    
    func drawLines() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 256)
            
            var first = true
            var length: CGFloat = 256
            
            //  Adding a line to more or less the same point inside a loop, but each time the loop rotates the CTM so the actual point the line ends has moved too. It will also slowly decrease the line length, causing the space between boxes to shrink like a spiral.
            for _ in 0 ..< 256 {
                ctx.cgContext.rotate(by: .pi / 2)
                
                // move(to:) and addLine(to:) are the Core Graphics equivalents to the UIBezierPath paths we made in project 20 to move the fireworks.
                if first {
                    ctx.cgContext.move(to: CGPoint(x: length, y: 50))
                    first = false
                } else {
                    ctx.cgContext.addLine(to: CGPoint(x: length, y: 50))
                }
                length *= 0.99
            }
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
        }
        imageView.image = image
    }
    
    func drawImgesAndText() {
        // 1. Create a renderer at the correct size.
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { ctx in
            // 2. Define a paragraph style that aligns text to the center.
            let paragaphStyle = NSMutableParagraphStyle()
            paragaphStyle.alignment = .center
            
            // 3. Create an attributes dictionary containing that paragraph style, and also a font.
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36),
                .paragraphStyle: paragaphStyle
            ]
            
            // 4. Wrap that attributes dictionary and a string into an instance of NSAttributedString.
            let string = "The best-laid schemes o'\nmice an' men gang aft agley"
            
            // attributed strings have a built-in method called draw(with:) that draws the string in a rectangle you specify.
            // Remarkably, the same is true of UIImage: any image can be drawn straight to a context, and it will even take into account the coordinate reversal of Core Graphics.
            let attributedString = NSAttributedString(string: string, attributes: attrs)
            // 5. Load an image from the project and draw it to the context.
            attributedString.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)
            
            let mouse = UIImage(named: "mouse")
            mouse?.draw(at: CGPoint(x: 300, y: 150))
        }
        // 6. Update the image view with the finished result.
        imageView.image = image
    }
    
    func drawEmoji() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 256)
            var rectangle = CGRect(x: -128, y: -128, width: 256, height: 256)
            ctx.cgContext.setShadow(offset: CGSize(width: 50, height: 50), blur: 20)
            
            ctx.cgContext.setFillColor(UIColor.yellow.cgColor)
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
            
            ctx.cgContext.beginPath()
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            for i in [-1, 1] {
                rectangle = CGRect(x: i * 40, y: -40, width: 10, height: 10)
                ctx.cgContext.addEllipse(in: rectangle)
            }
            
            ctx.cgContext.move(to: CGPoint(x: -50, y: 30))
            ctx.cgContext.addLine(to: CGPoint(x: 60, y: 30))
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        imageView.image = image
    }
    
    func spellTWIN() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 256)
            
            // T
            ctx.cgContext.move(to: CGPoint(x: -256, y: -128))
            ctx.cgContext.addLine(to: CGPoint(x: -100, y: -128))
            
            ctx.cgContext.move(to: CGPoint(x: -178, y: 50))
            ctx.cgContext.addLine(to: CGPoint(x: -178, y: -128))
            
            // W
            ctx.cgContext.move(to: CGPoint(x: -150, y: -100))
            ctx.cgContext.addLine(to: CGPoint(x: -100, y: 50))
            ctx.cgContext.rotate(by: .pi / -3)
            ctx.cgContext.addLine(to: CGPoint(x: 50, y: -100))
            ctx.cgContext.rotate(by: .pi / 3)
            ctx.cgContext.addLine(to: CGPoint(x: -50, y: 50))
            ctx.cgContext.rotate(by: .pi / -3)
            ctx.cgContext.addLine(to: CGPoint(x: 100, y: -20))
            // I
            ctx.cgContext.move(to: CGPoint(x: 0, y: 82))
            ctx.cgContext.addLine(to: CGPoint(x: 128, y: 10))
            
            // N
            ctx.cgContext.move(to: CGPoint(x: 30, y: 128))
            ctx.cgContext.addLine(to: CGPoint(x: 166, y: 50))
            ctx.cgContext.rotate(by: .pi / 6)
            ctx.cgContext.addLine(to: CGPoint(x: 166, y: 128))
            ctx.cgContext.rotate(by: .pi / -6)
            ctx.cgContext.addLine(to: CGPoint(x: 230, y: 110))
            
            // Set line width and stroke
            ctx.cgContext.setLineWidth(5)
            ctx.cgContext.strokePath()
        }
        imageView.image = image
    }
    
}

