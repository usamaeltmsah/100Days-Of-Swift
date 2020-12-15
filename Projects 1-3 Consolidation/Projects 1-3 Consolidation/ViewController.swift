//
//  ViewController.swift
//  Projects 1-3 Consolidation
//
//  Created by Usama Fouad on 12/14/20.
//

import UIKit

class ViewController: UITableViewController {
    
//    var flags = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Flags of the world"
        navigationController?.navigationBar.prefersLargeTitles = true
        
//        let fm = FileManager.default
//        let path = Bundle.main.resourcePath!
//        let items = try! fm.contentsOfDirectory(atPath: path)
//        for item in items {
//            if item.hasSuffix(".png") {
//                flags.append(item)
//            }
//        }
//
//        flags.sort()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryDict.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Country", for: indexPath)
        
        cell.imageView?.layer.cornerRadius = (cell.imageView?.bounds.width)! / 4
        
        cell.imageView?.addBorders(width: 1.5, color: UIColor.black.cgColor)
        
        cell.textLabel?.text = countryDict[sortedKeys[indexPath.row]]
        
        let image = UIImage(named: sortedKeys[indexPath.row].lowercased())
        
        let resized_image = image?.scaleImage(toSize: CGSize(width: 30, height: 15))
        
        cell.imageView?.image = resized_image
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1: try loading the "Detail" view controller and typecasting it to be DetailViewController
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            
            // 2: success! Set its selectedImage property
            vc.selectedImage = sortedKeys[indexPath.row].lowercased()
            // 3: now push it onto the navigation controller!
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}

