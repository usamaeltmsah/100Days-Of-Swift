//
//  siteJS.swift
//  Extension
//
//  Created by Usama Fouad on 21/01/2021.
//

import UIKit

class SiteJS: NSObject, Codable {
    var URL: String = ""
    var javaScript: String
    
    init(URL: String, javaScript: String) {
        self.URL = URL
        self.javaScript = javaScript
    }
}
