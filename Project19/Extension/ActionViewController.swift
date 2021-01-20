//
//  ActionViewController.swift
//  Extension
//
//  Created by Usama Fouad on 20/01/2021.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                    // Do stuff
                }
            }
        }
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

}