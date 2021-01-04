//
//  ViewController.swift
//  Projects10-12 Consolidation
//
//  Created by Usama Fouad on 04/01/2021.
//

import UIKit

class ViewController: UITableViewController, UIImagePickerControllerDelegate,  UINavigationControllerDelegate {

    var things = [Thing]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(addNewThing))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return things.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "thingCell", for: indexPath) as? ThingCell else {
            fatalError("Unable to dequeue a ThingCell")
        }
        
        let thing = things[indexPath.row]

        cell.captionLabel.text = thing.caption
        
        let path = getDocumentsDirectory().appendingPathComponent(thing.image)
            cell.thingImage.image = UIImage(contentsOfFile: path.path)

            cell.thingImage.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
            cell.thingImage.layer.borderWidth = 2
            cell.thingImage.layer.cornerRadius = 3
            cell.layer.cornerRadius = 7
        
        return cell
    }
    
    @objc func addNewThing() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        if(UIImagePickerController.isSourceTypeAvailable(.camera))
        {
            picker.sourceType = .camera
        }
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        let thing = Thing(caption: "None", image: imageName)
        things.append(thing)
        tableView.reloadData()
        
        dismiss(animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }

}

