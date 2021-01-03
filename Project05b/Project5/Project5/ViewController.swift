//
//  ViewController.swift
//  Project5
//
//  Created by Usama Fouad on 18/12/2020.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var userdWords = [String]()
    var currentWord = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(resetGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["Silkworm"]
        }
        currentWord = allWords.randomElement() ?? ""
        
        let defaults = UserDefaults.standard
        
        if let savedCurrentWord = defaults.object(forKey: "currentWord") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                currentWord = try jsonDecoder.decode(String.self, from: savedCurrentWord)
            } catch {
                print("Failed to load CurrentWord.")
            }
        }
        
        if let savedUserdWords = defaults.object(forKey: "userdWords") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                userdWords = try jsonDecoder.decode([String].self, from: savedUserdWords)
            } catch {
                print("Failed to load userdWords.")
            }
        }
        
        startGame()
    }
    
    @objc func resetGame() {
        userdWords.removeAll(keepingCapacity: true)
        currentWord = allWords.randomElement()!
        title = currentWord
        saveCurrentWord()
        tableView.reloadData()
    }
    
    @objc func startGame() {
        title = currentWord
        saveCurrentWord()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userdWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = userdWords[indexPath.row]
        
        return cell
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
                
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    userdWords.insert(answer.lowercased(), at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    saveUserWords()

                    return
                } else {
                    showErrorMessage(errorMessage: "You can't just make them up, you know!", errorTitle: "Word not recognised")
                }
            } else {
                showErrorMessage(errorMessage: "Be more original!", errorTitle: "Word used already")
            }
        } else {
            showErrorMessage(errorMessage: "You can't spell that word from \(title!)", errorTitle: "Word not possible")
        }
    }

    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }

    func isOriginal(word: String) -> Bool {
        return !userdWords.contains(word)
    }

    func isReal(word: String) -> Bool {
        let wordLen = word.utf16.count
        
        if wordLen < 3 || word == title {
            return false
        }
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: wordLen)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func showErrorMessage(errorMessage: String, errorTitle: String) {
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func saveCurrentWord() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(currentWord) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "currentWord")
        } else {
            print("Failed to save data")
        }
    }
    
    func saveUserWords() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(userdWords) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "userdWords")
        } else {
            print("Failed to save data")
        }
    }
}

