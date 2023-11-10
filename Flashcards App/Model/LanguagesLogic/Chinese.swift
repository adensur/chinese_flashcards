//
//  Hindi.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 25/08/2023.
//

import Foundation

class ChineseMatcher {
    static func chineseFilterOutRomans(_ s: String) -> String {
        // chinese qwerty keyboard outputs intermediate Roman/Pinyin characters before replacing tham with Chinese characters
        // we need to filter them out for suggest to work
        // 你hao -> 你
        return s.filter {ch in
            return !ch.isASCII
        }
    }
    
    static func findMatches(vocabCards: [String: VocabCard], inputText: String) -> [String] {
        let text = chineseFilterOutRomans(inputText.precomposedStringWithCanonicalMapping)
        let filteredTexts = vocabCards.keys.filter {vocabString in
            vocabString.hasUnicodePrefx(text)
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
