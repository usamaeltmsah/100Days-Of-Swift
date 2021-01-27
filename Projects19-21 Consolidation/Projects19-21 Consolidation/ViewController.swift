//
//  ViewController.swift
//  Projects19-21 Consolidation
//
//  Created by Usama Fouad on 25/01/2021.
//

import UIKit

class ViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet var searchBar: UISearchBar!
    
    var notes = [Note]() {
        didSet {
            filterdNotes = notes
        }
    }
    var filterdNotes = [Note]()

    var lastId: Int?
    var isSearching = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notes"
                
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(createNewNote))
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        searchBar.delegate = self
        
        if let _ = loadNotes() {
            filterdNotes = notes
        }
        
        if notes.isEmpty {
            lastId = 0
        }
        else {
            loadId()
        }
    }
    
    func loadNotes() -> [Note]? {
        let defaults = UserDefaults.standard
        
        if let data = defaults.object(forKey: "Notes") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                notes = try jsonDecoder.decode([Note].self, from: data)
            } catch {
                print("Couldn't load the notes!")
            }
        }
        return notes
    }
    
    func loadId() {
        let defaults = UserDefaults.standard
        
        if let data = defaults.object(forKey: "LastId") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                lastId = try jsonDecoder.decode(Int.self, from: data)
            } catch {
                print("Couldn't load the last id!")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterdNotes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        let cntxt = filterdNotes[indexPath.row].context
        
        let note = setNoteData(context: cntxt)
        
        cell.textLabel?.text = note.name
        cell.detailTextLabel?.text = note.context
        
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterdNotes = searchText.isEmpty ? notes : notes.filter { $0.context!.lowercased().contains(searchText.lowercased()) }

        tableView.reloadData()
    }
    
    func setNoteData(context: String?) -> Note {
        var note = Note()
        var texts = context?.split(separator: "\n")
        if !(texts?.isEmpty ?? false) {
//        if let title = context?.prefix(30) {
            if let title = texts?[0] {
                texts?.removeFirst()
                note.name = String(title)
//                if title.count < 1 {
//                    note.name = "New Note"
//                    note.context =  "No Additional text"
//                    return note
//                } else {
                    if let cntxt = texts?.joined(separator: "\n") {
    //                if let cntxt = context?[title.endIndex...] {
                        if cntxt.count < 1 {
                            note.context =  "No Additional text"
                        } else {
                            note.context = String(cntxt)
                        }
                    }
                }
//            }
        } else {
            note.name = "New Note"
            note.context =  "No Additional text"
        }
        
        return note
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "NoteStoryboard") as? DetailViewController {
            
            vc.note = notes[indexPath.row]
            vc.note?.id = indexPath.row
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func createNewNote() {
        if let vc = storyboard?.instantiateViewController(identifier: "NoteStoryboard") as? DetailViewController {
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func edit(id: Int, context: String) {
        notes[id].context = context
    }
    
    func add(context: String) {
        if let id = lastId {
        let note = Note(context: context, id: id)
            notes.insert(note, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
            lastId! += 1
            saveId()
        }
    }
    
    func delete(at index: Int) {
        notes.remove(at: index)
        save()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { [weak self] (_, _, _) in
            self?.deleteNote(at: indexPath.row)
        }
        let trashImage = UIImage(named: "trash")
        deleteAction.image = trashImage?.withTintColor(.white)
        deleteAction.backgroundColor = .red
        
        let shareAction = UIContextualAction(style: .normal, title: "Share") { [weak self] (_, _, _) in
            self?.share(at: indexPath.row)
        }
        let shareImage = UIImage(named: "share")
        shareAction.image = shareImage?.withTintColor(.white)
        shareAction.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)

        return UISwipeActionsConfiguration(actions: [shareAction, deleteAction])
    }
    
    func share(at index: Int) {
        guard let context = notes[index].context else { return }
        let vc = UIActivityViewController(activityItems: [context], applicationActivities: [])
        
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    func deleteNote(at index: Int) {
        let ac = UIAlertController(title: "Delete Note", message: "This note will be permanently deleted", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .destructive){ [weak self] _ in
            self?.delete(at: index)
            self?.tableView.reloadData()
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .default))
        present(ac, animated: true)
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(notes) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "Notes")
        } else {
            print("Failed to save data")
        }
    }
    
    func saveId() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(lastId) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "LastId")
        } else {
            print("Failed to save last id")
        }
    }


}

