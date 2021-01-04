//
//  Thing.swift
//  Projects10-12 Consolidation
//
//  Created by Usama Fouad on 04/01/2021.
//

import Foundation

class Thing: NSObject, Codable {
    var caption: String = ""
    var image: String
    
    init(caption: String, image: String) {
        self.caption = caption
        self.image = image
    }
}
