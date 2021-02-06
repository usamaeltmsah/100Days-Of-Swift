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
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Meme", for: indexPath)
        
        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            imageView.image = memes[indexPath.item]
        }
        
        return cell
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        
        AddTextToMeme(image)
    }
    
    func AddTextToMeme(_ image: UIImage) {
        let ac = UIAlertController(title: "Enter meme's text", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addTextField()
        ac.textFields?[0].placeholder = "Top text"
        ac.textFields?[1].placeholder = "Bottom text"
        let submitAction = UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            let topTxt = ac?.textFields?[0].text ?? ""
            let bottomTxt = ac?.textFields?[1].text ?? ""
            self?.sendData(image: image, topText: topTxt, bottomText: bottomTxt)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }


}

