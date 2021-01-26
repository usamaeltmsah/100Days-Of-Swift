//
//  ViewController.swift
//  Projects19-21 Consolidation
//
//  Created by Usama Fouad on 25/01/2021.
//

import UIKit

class ViewController: UITableViewController {

    var notes = [Note]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notes"
                
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewNote))
        
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        
        let cntxt = notes[indexPath.row].context
        
        let note = setNoteData(context: cntxt)
        
        cell.textLabel?.text = note.name
        cell.detailTextLabel?.text = note.context
        
        return cell
    }
    
    func  setNoteData(context: String?) -> Note {
        var note = Note()
        if let title = context?.prefix(30) {
            note.name = String(title)
            if title.count < 1 {
                note.name = "New Note"
                note.context =  "No Additional text"
                return note
            } else {
                if let cntxt = context?[title.endIndex...] {
                    if cntxt.count < 1 {
                        note.context =  "No Additional text"
                    } else {
                        note.context = String(cntxt)
                    }
                }
            }
        }
        
        return note
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "NoteStoryboard") as? DetailViewController {
            
            vc.note = notes[indexPath.row]
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


}

