//
//  DetailViewCellViewController.swift
//  Project07
//
//  Created by Usama Fouad on 22/12/2020.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    var webView: WKWebView!
    var detailItem: Petition?
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let detailItem = detailItem else { return }
        
        let html = """
        <html>
            <head>
                <h1>\(title!)</h1>
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <style> body { font-size: 200%; font-family: Monospace; color: rgb(0, 91, 227);} h1 { font-size: 70%; font-family: "Times New Roman", Times, serif; color: red }</style>
            </head>
            <body>
                \(detailItem.body)
            </body>
        </html>
        """
        
        webView.loadHTMLString(html, baseURL: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
