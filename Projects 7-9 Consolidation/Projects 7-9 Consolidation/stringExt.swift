//
//  stringExt.swift
//  Projects 7-9 Consolidation
//
//  Created by Usama Fouad on 29/12/2020.
//

import Foundation

extension String {
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex

        while searchStartIndex < self.endIndex,
            let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
            !range.isEmpty {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }

        return indices
    }
    
    mutating func replace(at indices: [Int], with newChar: String) {
        var chars = Array(self)     // gets an array of characters
        for i in indices {
            chars[i] = Character(newChar)
        }
        
        self = String(chars)
    }
}
