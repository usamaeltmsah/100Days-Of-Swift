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
        // UIApplication.willResignActiveNotification: watch for another notification that will tell us when the application will stop being active – i.e., when our app has been backgrounded or the user has switched to multitasking mode.
        // automatically saves any text and hides it when the app is moving to a background state.
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
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
    
    @objc func saveSecretMessage() {
        // saveSecretMessage(): needs to write the text view's text to the keychain, then make it hidden.
        guard secret.isHidden == false else { return }
        
        // KeychainWrapper class is needed because working with the keychain is complicated. So instead of using it directly, we'll be using this wrapper class that makes the keychain work like UserDefaults.
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        // resignFirstResponder(): Used to tell a view that has input focus that it should give up that focus. Or, in Plain English, to tell our text view that we're finished editing it, so the keyboard can be hidden. This is important because having a keyboard present might arouse suspicion – as if our rather obvious navigation bar title hadn't done enough already…
        secret.resignFirstResponder()
        secret.isHidden = true
        title = "Nothing to see here"
    }
}

