import UIKit

/// Swift’s strings isn't look like arrays of letters.

var name = "Usama Fouad"

for letter in name {
    print("Give me a \(letter)!")
}

// Reason fo that Strings aren’t just a series of alphabetical characters – they can contain accents such as á, é, í, ó, or ú, they can contain combining marks that generate wholly new characters by building up symbols, or they can even be emoji.

// Go through the name string, pull out the characters starts from the first index and offsetBy 3 (The 4th character)

// Because of this, if you want to read the fourth character of name you need to start at the beginning and count through each letter until you come to the one you’re looking for:

let letter = name[name.index(name.startIndex, offsetBy: 3)]

// Apple could change this easily enough by adding a rather complex extension like this:
extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}


// Now you can use it like this:
let letter2 = name[3]

// However, it creates the possibility that someone might write code that loops over a string reading individual letters, which they might not realize creates a loop within a loop and has the potential to be slow.

// Similarly, reading name.count isn’t a quick operation: Swift literally needs to go over every letter counting up however many there are, before returning that. As a result, it’s always better to use someString.isEmpty rather than someString.count == 0 if you’re looking for an empty string.
