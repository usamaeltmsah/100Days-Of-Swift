//
//  ViewController.swift
//  Project10
//
//  Created by Usama Fouad on 30/12/2020.
//

import LocalAuthentication
import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var people = [Person]()
    var unlockButton: UIBarButtonItem!
    var addImageButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addImageButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        unlockButton = UIBarButtonItem(title: "Unlock", style: .plain, target: self, action: #selector(authenticate))
        addImageButton.isEnabled = false
        unlockButton.isEnabled = true
        navigationItem.leftBarButtonItem = addImageButton
        navigationItem.rightBarButtonItem = unlockButton
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(savePeople), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue a PersonCell")
        }
        
        let person = people[indexPath.item]

        cell.name.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
            cell.imageView.image = UIImage(contentsOfFile: path.path)

            cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
            cell.imageView.layer.borderWidth = 2
            cell.imageView.layer.cornerRadius = 3
            cell.layer.cornerRadius = 7
        
        return cell
    }
    
    @objc func addNewPerson() {
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
        
        let person = Person(name: "Unkown", image: imageName)
        people.append(person)
        save()
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let ac = UIAlertController(title: "Choose an action", message: nil, preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Rename", style: .default) {[weak self] _ in
            self?.renamePerson(at: indexPath)
        })
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self]_ in
            self?.deletePerson(at: indexPath)
        })
        present(ac, animated: true)
    }
    
    func renamePerson(at indexPath: IndexPath) {
        let person = people[indexPath.item]
        let ac = UIAlertController(title: "Rename Person", message: nil, preferredStyle: .alert)
        ac.addTextField()

        ac.addAction(UIAlertAction(title: "OK", style: .default){ [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else {
                return
            }
            person.name = newName
            self?.save()
            self?.collectionView.reloadData()
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .default))
        present(ac, animated: true)
    }
    
    func deletePerson(at indexPath: IndexPath) {
        let ac = UIAlertController(title: "Delete Person", message: "This item will be permanently deleted", preferredStyle: .alert)

        ac.addAction(UIAlertAction(title: "OK", style: .destructive){ [weak self] _ in
            self?.people.remove(at: indexPath.item)
            self?.collectionView.reloadData()
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .default))
        present(ac, animated: true)
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(people) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "people")
        } else {
            print("Failed to save people")
        }
    }
    
    @objc func authenticate() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "IUnlock to access the app's data!"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {[weak self] success,authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockApp()
                    } else {
                        self?.enterPassword()
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device isn't configured for biometric authentication.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func unlockApp() {
        title = "People"
        
        loadPeople()
        collectionView.reloadData()
        addImageButton.isEnabled = true
        unlockButton.isEnabled = false
    }
    
    @objc func savePeople() {
        guard !people.isEmpty else { return }
        
        save()
        
        people = []
        collectionView.reloadData()
        
        addImageButton.isEnabled = false
        unlockButton.isEnabled = true
        title = "People is hidden!"
    }
    
    func loadPeople() {
        let defaults = UserDefaults.standard
        
        if let savedPeople = defaults.object(forKey: "people") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                people = try jsonDecoder.decode([Person].self, from: savedPeople)
            } catch {
                print("Failed to load people.")
            }
        }
    }
    
    func enterPassword() {
        
    }
}

