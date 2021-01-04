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
        
        let defaults = UserDefaults.standard
        
        if let savedPeople = defaults.object(forKey: "things") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                things = try jsonDecoder.decode([Thing].self, from: savedPeople)
            } catch {
                print("Failed to load things.")
            }
        }
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
        save()
        tableView.reloadData()
        
        dismiss(animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    func editThingCaption(at indexPath: IndexPath) {
        let thing = things[indexPath.row]
        let ac = UIAlertController(title: "Edit the caption", message: nil, preferredStyle: .alert)
        ac.addTextField()

        ac.addAction(UIAlertAction(title: "OK", style: .default){ [weak self, weak ac] _ in
            guard let caption = ac?.textFields?[0].text else {
                return
            }
            thing.caption = caption
            self?.save()
            self?.tableView.reloadData()
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .default))
        present(ac, animated: true)
    }
    
    func deleteThing(at indexPath: IndexPath) {
        let ac = UIAlertController(title: "Delete Thing", message: "This item will be permanently deleted", preferredStyle: .alert)

        ac.addAction(UIAlertAction(title: "OK", style: .destructive){ [weak self] _ in
            self?.things.remove(at: indexPath.item)
            self?.tableView.reloadData()
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .default))
        present(ac, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, _) in
            self?.editThingCaption(at: indexPath)
        }
            editAction.backgroundColor = .orange

        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { [weak self] (_, _, _) in
            self?.deleteThing(at: indexPath)
            }
            deleteAction.backgroundColor = .red

            return UISwipeActionsConfiguration(actions: [editAction,deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            let thing = things[indexPath.row]
            
            vc.caption = thing.caption
            
            let path = getDocumentsDirectory().appendingPathComponent(thing.image)
            
            vc.imagePath = path.path
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(things) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "things")
        } else {
            print("Failed to save things")
        }
    }

}

