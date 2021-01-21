//
//  ActionViewController.swift
//  Extension
//
//  Created by Usama Fouad on 20/01/2021.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    @IBOutlet var script: UITextView!
    
    var pageTitle = ""
    var pageURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        // addObserver() method, takes four parameters: the object that should receive notifications (it's self), the method that should be called, the notification we want to receive, and the object we want to watch.
        
        // keyboardWillHideNotification: will be sent when the keyboard has finished hiding.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // keyboardWillChangeFrameNotification: will be shown when any keyboard state change happens – including showing and hiding, but also orientation, QuickType and more.
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // extensionContext: lets us control how it interacts with the parent app.
        // inputItems: is an array of data the parent app is sending to our extension to use.
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            // Our input item contains an array of attachments.
            if let itemProvider = inputItem.attachments?.first {
                // loadItem(forTypeIdentifier:): Ask the item provider to actually provide us with its item.
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) {
                    // dict: dictionary that was given to us by the item provider.
                    // error: any error that occurred.
                    [weak self] (dict, error) in
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                    
                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                    }
                }
            }
        }
    }

    @IBAction func done() {
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": script.text!]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]
        extensionContext?.completeRequest(returningItems: [item])
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        // UIResponder.keyboardFrameEndUserInfoKey: telling us the frame of the keyboard after it has finished animating.
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        // Adjust the contentInset and scrollIndicatorInsets of the text view.
        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = .zero
        } else {
            // UIEdgeInsets(): used to setting the inset of a text view
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        script.scrollIndicatorInsets = script.contentInset
        
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }

}
