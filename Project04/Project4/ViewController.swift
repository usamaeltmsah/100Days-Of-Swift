//
//  ViewController.swift
//  Project4
//
//  Created by Usama Fouad on 15/12/2020.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var progressView: UIProgressView!
    var websites = ["github.com/usamaeltmsah/", "mobile.twitter.com/usama_fouad/", "www.google.com/search?q=cats", "m.facebook.com/login"]
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
        let toolBarItems = [UIBarButtonItem(title: "←", style: .plain, target: webView, action: #selector(webView.goBack)), UIBarButtonItem(title: "→", style: .plain, target: webView, action: #selector(webView.goForward))
        ]
        
        navigationItem.leftBarButtonItems = toolBarItems
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        
        toolbarItems = [refresh, spacer, progressButton]
        navigationController?.isToolbarHidden = false
        
        let url = URL(string: "https://"+(websites[0]))!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }

    @objc func openTapped() {
        let ac = UIAlertController(title: "Open page…", message: nil, preferredStyle: .actionSheet)
        for website in websites {
            ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        // Used only on iPad, and tells iOS where it should make the action sheet be anchored.
        ac.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }
    
    func openPage(action: UIAlertAction) {
        let url = URL(string: "https://" + action.title!)!
        webView.load(URLRequest(url: url))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        
        if let host = url?.host {
            for website in websites {
                if website.contains(host) {
                    decisionHandler(.allow)
                    return
                }
            }
        }
        
        let alert = UIAlertController(title: "Blocked page", message: "\((url?.host)!) isn't in your safe urls. Do you want to continue, and keep it as a safe domain?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: {(alert: UIAlertAction!) in decisionHandler(.cancel)}))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [self](alert: UIAlertAction!) in
            decisionHandler(.allow)
            websites.append((url?.host)!)
            return
        }))
        present(alert, animated: true)
    }
}

