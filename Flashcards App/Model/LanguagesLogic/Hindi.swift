//
//  Hindi.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 25/08/2023.
//

import Foundation

class HindiMatcher {
    static func hindiNormalizedString(_ s: String) -> String {
        // replace some symbols to make potential writing mistakes less likely
        // आ -> अ
        // का -> क
        var result = ""
        for char in s.unicodeScalars {
            switch char {
            case "आ":
                result.append("अ")
            case "ा":
                // pass
                ()
            case "ू":
                result.append("ु")
            case "ऊ":
                result.append("उ")
            case "ौ":
                result.append("ो")
            case "औ":
                result.append("ओ")
            case "ी":
                result.append("ि")
            case "ई":
                result.append("इ")
            case "ै":
                result.append("े")
            case "ऐ":
                result.append("ए")
            case "्":
                // pass
                ()
            default:
                result.append(Character(char))
            }
        }
        return result
    }
    
    static func findMatches(vocabCards: [String: VocabCard], inputText: String) -> [String] {
        let text = hindiNormalizedString(inputText.precomposedStringWithCanonicalMapping)
        let filteredTexts = vocabCards.keys.filter {vocabString in
            // Hindi-normalise
            hindiNormalizedString(vocabString).hasUnicodePrefx(text)
        }
        return filteredTexts.sorted {lhs, rhs in
            if lhs.utf8.count == rhs.utf8.count {
                // shortest matches first
                return lhs < rhs
            } else {
                return lhs.utf8.count < rhs.utf8.count
            }
        }
    }
}
