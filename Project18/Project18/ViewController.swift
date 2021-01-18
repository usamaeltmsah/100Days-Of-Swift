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
        
        /// 1. Assertions
            //  Assertions are removed when we build our apps for the App Store.
        
//        let errMsg = "Math Failure!"
//        assert(1 == 1, errMsg)
//        assert(1 == 2, errMsg)
        
        // 2. Breakpoint with a condition
        // fn + F6 => To carry on execution
        // (Ctrl+Cmd+Y) => Continue executing my program until you hit another breakpoint
        
        for i in 1...100 {
            print("Got number \(i).")
        }
        
        // 3. Exception Break point => It will help you find your bug easily
            // In the left Navigator in Xcode
                // Select "Show the Breakpoint navigator item" from the top list
                    // Or just click [CMD + 8] as a shortcut
                // Then choose from the left button + icon ...
        /// 4. Interactive LLDB (lldb) debugger window => where you can type commands to query values and run methods
        
        /// 5. Capture View Hierarchy (3D representation)
        /*
         Debug menu > Choose View Debugging -> Capture View Hierarchy (In the Debugging area at the buttom)
         */
    }


}

