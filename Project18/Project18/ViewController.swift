//
//  ViewController.swift
//  Project18
//
//  Created by Usama Fouad on 17/01/2021.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let errMsg = "Math Failure!"
//        assert(1 == 1, errMsg)
//        assert(1 == 2, errMsg)
        
        // Breakpoint with a condition
        for i in 1...100 {
            print("Got number \(i).")
        }
        
        // Try use Exception Break point => It will help you find your bug easily
            // In the left Navigator in Xcode
                // Select "Show the Breakpoint navigator item" from the top list
                    // Or just click [CMD + 8] as a shortcut
                // Then choose from the left button + icon ...
    }


}

