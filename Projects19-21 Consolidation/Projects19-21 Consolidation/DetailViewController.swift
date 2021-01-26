//
//  DetailViewController.swift
//  Projects19-21 Consolidation
//
//  Created by Usama Fouad on 25/01/2021.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var textView: UITextView!
    
    var delegate: ViewController?
    
    var note: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = note?.name
        textView.text = note?.context
        navigationItem.largeTitleDisplayMode = .never
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteNote))
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareNote))
        
        navigationItem.rightBarButtonItems = [doneButton, shareButton, deleteButton]
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        textView.scrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    @objc func done() {
//        save()
        delegate?.notes.append(Note(name: note?.context, context: textView.text))
        delegate?.tableView.reloadData()
    }
    
    @objc func deleteNote() {
        
    }
    
    @objc func shareNote() {
        guard let note = textView.text else { return }
        let vc = UIActivityViewController(activityItems: [note], applicationActivities: [])
        
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }

}
