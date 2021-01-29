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


// There are methods for checking whether a string starts with or ends with a substring: hasPrefix() and hasSuffix().
let password = "12345"
password.hasPrefix("123")
password.hasSuffix("345")


// We can add extension methods to String to extend the way prefixing and suffixing works:

extension String {
    // Remove a prefix if it exists
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    // Remove a suffix if it exists
    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
       return String(self.dropLast(suffix.count))
    }
    
    // That uses the dropFirst() and dropLast() method of String, which removes a certain number of letters from either end of the string.
    
    
    /// We could add our own specialized capitalization that uppercases only the first letter in our string:
    var capitalizedFirst: String {
        guard let firstLetter = self.first else { return "" }
        return firstLetter.uppercased() + self.dropFirst()
    }
}

let weather = "it's going to rain"
print(weather.capitalized)


// Individual letters in strings aren’t instances of String, but are instead instances of Character – a dedicated type for holding single-letters of a string.
// So, that uppercased() method is actually a method on Character rather than String. However, where things get really interesting is that Character.uppercased() actually returns a string, not an uppercased Character.
// Language is complicated, and although many languages have one-to-one mappings between lowercase and uppercase characters, some do not.
// For example, in English “a” maps to “A”, “b” to “B”, and so on, but in German “ß” becomes “SS” when uppercased. “SS” is clearly two separate letters, so uppercased() has no choice but to return a string.

// Contains
let input = "Swift is like Objective-C without the C"
input.contains("Swift")

let languages = ["Python", "Ruby", "Swift"]
languages.contains("Swift")


extension String {
    func containsAny(of array: [String]) -> Bool {
        for item in array {
            if self.contains(item) {
                return true
            }
        }
        return false
    }
}

input.containsAny(of: languages)

// Arrays have a contains(where:)

    // This lets us provide a closure that accepts an element from the array as its only parameter and returns true or false depending on whatever condition we decide we want. This closure gets run on all the items in the array until one returns true, at which point it stops.

    // When used with an array of strings, the contains(where:) method wants to call a closure that accepts a string and returns true or false.
    
    // The contains() method of String accepts a string as its parameter and returns true or false.

    // Swift massively blurs the lines between functions, methods, closures, and more.


languages.contains(where: input.contains)

// contains(where:) will call its closure once for every element in the languages array until it finds one that returns true, at which point it stops.

// In that code we’re passing input.contains as the closure that contains(where:) should run. This means Swift will call input.contains("Python") and get back false, then it will call input.contains("Ruby") and get back false again, and finally call input.contains("Swift") and get back true – then stop there.

// So, because the contains() method of strings has the exact same signature that contains(where:) expects (take a string and return a Boolean), this works perfectly – this's how Swift blurs the lines between these things?
