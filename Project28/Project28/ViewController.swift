//
//  ViewController.swift
//  Project28
//
//  Created by Usama Fouad on 08/02/2021.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var secret: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nothing to see here"
        
        let notificationCenter = NotificationCenter.default
        //  watch for the keyboard disappearing
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        // watch for the keyboard appearing
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @IBAction func authenticateTapped(_ sender: Any) {
        unlockSecretMessage()
    }
    
    @objc func adjustForKeyboard(notification : Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEnd = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEnd, from: view.window)
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    func unlockSecretMessage() {
        // unlockSecretMessage(): Load the message into the text view.
        secret.isHidden = false
        title = "Secret stuff!"
        
        // Loading strings from the keychain using KeychainWrapper is as simple as using its string(forKey:) method.
        secret.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? ""
    }
}

