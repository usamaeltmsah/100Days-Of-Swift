//
//  ViewController.swift
//  Project1
//
//  Created by Usama Fouad on 12/8/20.
//

import UIKit

var selectedPictureNumber: Int!
var totalPictures: Int!

class ViewController: UICollectionViewController {
    
    var pictures = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm Viewer"
                
        navigationController?.navigationBar.prefersLargeTitles = true

        // Do any additional setup after loading the view.
        
        performSelector(inBackground: #selector(loadNsslImages), with: nil)
        
        collectionView.performSelector(onMainThread: #selector(UICollectionView.reloadData), with: nil, waitUntilDone: false)
    }
    
    @objc func loadNsslImages() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("nssl") {
                pictures.append(item)
            }
        }
        
        pictures.sort()
        totalPictures = pictures.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Picture", for: indexPath) as? imgCell else {
            fatalError("Unable to dequeue a imgCell")
        }
        
        
        let imgName = pictures[indexPath.item]
        cell.imageName.text = imgName
        cell.imageView.image = UIImage(named: imgName)
        cell.imageName.setSizeFont(24.0)
        
        cell.imageView.layer.borderColor = UIColor(white: 1, alpha: 0.5).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 1: try loading the "Detail" view controller and typecasting it to be DetailViewController
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            
            // 2: success! Set its selectedImage property
            vc.selectedImage = pictures[indexPath.row]
            
            // 3: now push it onto the navigation controller!
            navigationController?.pushViewController(vc, animated: true)
            
            selectedPictureNumber = indexPath.row + 1

        }
    }
}

extension UILabel {
    func setSizeFont (_ fontSize: Double) {
        self.font =  UIFont(name: self.font.fontName, size: CGFloat(fontSize))!
        self.sizeToFit()
    }
}
