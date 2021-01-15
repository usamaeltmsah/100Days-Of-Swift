//
//  WekepediaWebViewController.swift
//  Project16
//
//  Created by Usama Fouad on 15/01/2021.
//

import WebKit
import UIKit

class WekepediaWebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var progressView: UIProgressView!
    var wikipedia = "https://en.wikipedia.org/wiki/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
