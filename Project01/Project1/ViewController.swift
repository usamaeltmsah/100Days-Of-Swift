//
//  ViewController.swift
//  Project1
//
//  Created by Usama Fouad on 12/8/20.
//

import UIKit

var selectedPictureNumber: Int!
var totalPictures: Int!

class ViewController: UITableViewController {
    
    var pictures = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm Viewer"
                
        navigationController?.navigationBar.prefersLargeTitles = true

        // Do any additional setup after loading the view.
        
        performSelector(inBackground: #selector(loadNsslImages), with: nil)
        
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        
        cell.textLabel?.text = pictures[indexPath.row]
        
        cell.textLabel?.setSizeFont(40.0)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
