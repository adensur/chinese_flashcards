//
//  Vocab.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 17/07/2023.
//

import Foundation
import Zip
import FirebaseStorage

func getVocabPath(languageFrom: String, languageTo: String) -> URL{
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    return documentsDirectory.appendingPathComponent("vocabs/\(languageFrom)_\(languageTo).json")
}

class VocabCard {
    let frontText: String
    let backText: String
    let frequency: Int
    let audioData: Data?
//    let translations: [Translation]
    init(frontText: String, backText: String, frequency: Int, audioData: Data?) {
        self.frontText = frontText
        self.backText = backText
        self.audioData = audioData
        self.frequency = frequency
    }
}

struct Translation: Codable {
    var translation: String
    var frequency: Int
    var type: String
}

struct Translations: Codable {
    var word: String
    var translations: [Translation]
}

class Vocab {
    var cards: [String: VocabCard] = [:]
    var languageFrom: String
    init(cards: [VocabCard], languageFrom: String) {
        self.languageFrom = languageFrom
        for card in cards {
            self.cards[card.frontText] = card
        }
    }
    
    static func loadV2(languageFrom: String, languageTo: String) -> Vocab? {
        let fileURL = getVocabPath(languageFrom: languageFrom, languageTo: languageTo)
        var cards: [VocabCard] = []
        if let data = try? String(contentsOf: fileURL) {
            print("Loading vocab from \(fileURL)")
            // first line is version metadata
            for line in data.split(separator: "\n").dropFirst(1) {
                let decoder = JSONDecoder()
                if let translations = try? decoder.decode(Translations.self, from: Data(line.utf8)) {
                    if let translation = translations.translations.first {
                        cards.append(.init(frontText: translations.word, backText: translation.translation, frequency: translation.frequency, audioData: nil))
                    }
                }
            }
            return Vocab(cards: cards, languageFrom: languageFrom)
        } else {
            return nil
        }
    }
    
    func findMatches(_ inputText: String) -> [String] {
        switch languageFrom {
        case "hi":
            return HindiMatcher.findMatches(vocabCards: cards, inputText: inputText)
        default:
            let filteredTexts = cards.keys.filter {vocabString in
                // we need
                vocabString.hasUnicodePrefx(inputText.precomposedStringWithCanonicalMapping)
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
}

let previewVocab = vocabs.getVocab(languageFrom: "hi", languageTo: "en")!
