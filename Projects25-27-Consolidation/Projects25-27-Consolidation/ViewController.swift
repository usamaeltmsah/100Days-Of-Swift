//
//  ViewController.swift
//  Projects25-27-Consolidation
//
//  Created by Usama Fouad on 06/02/2021.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    var memes = [UIImage]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Meme Generator"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPicture))
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }


}

