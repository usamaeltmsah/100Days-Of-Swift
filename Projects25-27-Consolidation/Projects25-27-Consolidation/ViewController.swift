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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
                
            vc.image = memes[indexPath.item]
            
            navigationController?.pushViewController(vc, animated: true)
        }
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
    
    func sendData(image: UIImage, topText: String, bottomText: String) {
        let meme = addTextToImg(img: image, topText: topText, bottomText: bottomText)
        memes.insert(meme, at: 0)
        collectionView.reloadData()
    }
    
    func addTextToImg(img: UIImage, topText: String, bottomText: String) -> UIImage {
        let size = img.size
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { ctx in
            img.draw(at: CGPoint(x: 0, y: 0))
            
            let paragaphStyle = NSMutableParagraphStyle()
            paragaphStyle.alignment = .center
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Courier-BoldOblique", size: 100) ?? UIFont.systemFont(ofSize: 100),
                .paragraphStyle: paragaphStyle,
                .strokeColor: UIColor.white.cgColor,
                .backgroundColor: UIColor(white: 0, alpha: 0.5),
                .strokeWidth: 5
            ]
            
            let texts = [topText, bottomText]
            for i in 0 ... 1 {
                let attributedString = NSAttributedString(string: texts[i], attributes: attrs)
                
                attributedString.draw(with: CGRect(x: 32, y: CGFloat(32 + i * Int(size.height - 250)), width: size.width - 50, height: size.height - 50), options: .usesLineFragmentOrigin, context: nil)
            }
        }
        return image
    }


}

