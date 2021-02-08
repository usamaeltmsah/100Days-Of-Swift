//
//  ViewController.swift
//  Project28
//
//  Created by Usama Fouad on 08/02/2021.
//

import LocalAuthentication
import UIKit

class ViewController: UIViewController {

    @IBOutlet var secret: UITextView!
    var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nothing to see here"
        
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveSecretMessage))
        
        navigationItem.rightBarButtonItem = doneButton
        
        doneButton.isEnabled = false
        
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
        // Touch ID and Face ID are part of the Local Authentication framework
        let context = LAContext()
        var error: NSError?
        
        // 1. Check whether the device is capable of supporting biometric authentication – that the hardware is available and is configured by the user.
        // MARK: &error: The LocalAuthentication framework uses the Objective-C approach to reporting errors back to us, which is where the NSError type comes from – where Swift likes to have an enum that conforms to the Error protocol, Objective-C had a dedicated NSError type for handling errors.
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            // 2. If so, request that the biometry system begin a check now, giving it a string containing the reason why we're asking. For Touch ID the string is written in code; for Face ID the string is written into our Info.plist file.
            
                // Instead what we use is the Objective-C equivalent of Swift’s inout parameters: we pass an empty NSError variable into our call to canEvaluatePolicy(), and if an error occurs that error will get filled with a real NSError instance telling us what went wrong.
                // Objective-C’s equivalent to inout is what’s called a pointer, so named because it effectively points to a place in memory where something exists rather us passing around the actual value instead. If we had passed error into the method, it would mean “here’s the error you should use.” By passing in &error – Objective-C’s equivalent of inout – it means “if you hit an error, here’s the place in memory where you should store that error so I can read it.”
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {[weak self] success,authenticationError in
                DispatchQueue.main.async {
                    // when we're told whether Touch ID/Face ID was successful or not, it might not be on the main thread. This means we need to use async() to make sure we execute any user interface code on the main thread.
                    if success {
                        // 3. If we get success back from the authentication request it means this is the device's owner so we can unlock the app.
                        self?.unlockSecretMessage()
                    } else {
                        // 4. otherwise we show a failure message.
                        let ac = UIAlertController(title: "Authentication failed!", message: "You couldn't be verified; please try again.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(ac, animated: true)
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device isn't configured for biometric authentication.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
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
        
        doneButton.isEnabled = true
    }
    
    @objc func saveSecretMessage() {
        // saveSecretMessage(): needs to write the text view's text to the keychain, then make it hidden.
        guard secret.isHidden == false else { return }
        
        doneButton.isEnabled = false
        // KeychainWrapper class is needed because working with the keychain is complicated. So instead of using it directly, we'll be using this wrapper class that makes the keychain work like UserDefaults.
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        // resignFirstResponder(): Used to tell a view that has input focus that it should give up that focus. Or, in Plain English, to tell our text view that we're finished editing it, so the keyboard can be hidden. This is important because having a keyboard present might arouse suspicion – as if our rather obvious navigation bar title hadn't done enough already…
        secret.resignFirstResponder()
        secret.isHidden = true
        title = "Nothing to see here"
    }
}

