//
//  ViewController.swift
//  Project15
//
//  Created by Usama Fouad on 11/01/2021.
//

import UIKit

class ViewController: UIViewController {
    var imageView: UIImageView!
    var currentAnimation = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView(image: UIImage(named: "penguin"))
        imageView.center = CGPoint(x: 512, y: 384)
        view.addSubview(imageView)
    }
    
    @IBAction func tapped(_ sender: UIButton) {
        sender.isHidden = true
       
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], animations: {
//        UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
                switch self.currentAnimation {
                case 0:
                    self.imageView.transform = CGAffineTransform(scaleX: 2, y: 2)
                    sender.setTitle("Back Again!", for: .normal)
                case 1:
                    self.imageView.transform = .identity
                    sender.setTitle("Go up!", for: .normal)
                case 2:
                    self.imageView.transform = CGAffineTransform(translationX: -256, y: -256)
                    sender.setTitle("Back Again!", for: .normal)
                case 3:
                    self.imageView.transform = .identity
                    sender.setTitle("Rotate!", for: .normal)
                case 4:
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi)
                    sender.setTitle("Back Again!", for: .normal)
                case 5:
                    self.imageView.transform = .identity
                    sender.setTitle("Hide!", for: .normal)
                case 6:
                    self.imageView.alpha = 0.1
                    self.imageView.backgroundColor = .green
                    sender.setTitle("Back Again!", for: .normal)
                case 7:
                    self.imageView.alpha = 1
                    self.imageView.backgroundColor = .clear
                    sender.setTitle("Scale Up", for: .normal)
                default:
                    break
                }
            }) { finished in
                sender.isHidden = false
            }

        currentAnimation += 1
        
        if currentAnimation > 7 {
            currentAnimation = 0
        }
    }
}

