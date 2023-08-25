//
//  Vocab.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 17/07/2023.
//

import Foundation
import Zip
import FirebaseStorage

class VocabCard {
    let frontText: String
    let backText: String
    let audioData: Data?
    init(frontText: String, backText: String, audioData: Data?) {
        self.frontText = frontText
        self.backText = backText
        self.audioData = audioData
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

fileprivate func getVocabPath(languageFrom: String, languageTo: String) -> URL{
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    return documentsDirectory.appendingPathComponent("vocabs/\(languageFrom)_\(languageTo).json")
}

class Vocab {
    var cards: [String: VocabCard] = [:]
    init(cards: [VocabCard]) {
        for card in cards {
            self.cards[card.frontText] = card
        }
    }
    
    static func loadV2(languageFrom: String, languageTo: String) -> Vocab{
        let fileURL = getVocabPath(languageFrom: languageFrom, languageTo: languageTo)
        var cards: [VocabCard] = []
        if let data = try? String(contentsOf: fileURL) {
            print("Loading vocab from \(fileURL)")
            // first line is version metadata
            for line in data.split(separator: "\n").dropFirst(1) {
                let decoder = JSONDecoder()
                if let translations = try? decoder.decode(Translations.self, from: Data(line.utf8)) {
                    if let translation = translations.translations.first {
                        cards.append(.init(frontText: translations.word, backText: translation.translation, audioData: nil))
                    }
                }
            }
            return Vocab(cards: cards)
        } else {
            return Vocab(cards: cards)
        }
    }
}

func load() -> Vocab {
    let vocab = Vocab(cards: [])
    for archive in ["hindipod_rich_2k", "hindi_duolinguo_400"] {
        print("Processing archive: \(archive)")
        // check if it was unzipped before
        let unzipPath = try! FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ).appendingPathComponent(archive).appendingPathComponent(archive)
        if !FileManager.default.fileExists(atPath: unzipPath.relativePath) {
            let filePath = Bundle.main.url(forResource: archive, withExtension: "zip")!
            let unzipDirectory = try! Zip.quickUnzipFile(filePath).appendingPathComponent(archive) // Unzip
            print("Unzipped! ", unzipDirectory)
        }
        print("Unzip Path: ", unzipPath)
        let content = try! String(contentsOf: unzipPath.appendingPathComponent("vocab.tsv"))
        let lines = content.split(separator: "\n")
        // split the header of lines
        for line in lines.dropFirst(1) {
            let values = line.split(separator: "\t", omittingEmptySubsequences: false)
            let frontText = String(values[0]).precomposedStringWithCanonicalMapping
            let backText = String(values[1]).precomposedStringWithCanonicalMapping
            let audioId = String(values[6])
            print(audioId)
            let audioData: Data?
            if audioId.count > 0 {
                audioData = try? Data(contentsOf: unzipPath.appendingPathComponent("audio").appendingPathComponent(audioId))
                print("Audio data len: ", audioData!.count)
            } else {
                audioData = nil
            }
            vocab.cards[frontText] = VocabCard(frontText: frontText, backText: backText, audioData: audioData)
        }
    }
    return vocab
}

let defaultVocab: Vocab = load()

let vocabs = Vocabs()

class Vocabs {
    // languageFrom -> languageTo -> Vocab, like hi -> en -> Vocab
    // nil when we checked the file and it was not there
    // no entry when we haven't checked
    var vocabs: [String: [String: Vocab?]] = [:]
    
    func getVocab(languageFrom: String, languageTo: String) -> Vocab? {
        if let dic = vocabs[languageFrom] {
            if let vocab = dic[languageTo] {
                return vocab
            }
        }
        let vocab = Vocab.loadV2(languageFrom: languageFrom, languageTo: languageTo)
        if vocabs[languageFrom] == nil {
            vocabs[languageFrom] = [:]
        }
        vocabs[languageFrom]![languageTo] = vocab
        return vocab
    }
    
    func updateVocab(languageFrom: String, languageTo: String, path: String, callback: @escaping (Bool) -> Void) {
        print("Downloading vocab for languages: \(languageFrom)-\(languageTo) from path: \(path)")
        let storage = Storage.storage()
        let pathReference = storage.reference(withPath: path)
        pathReference.write(toFile: getVocabPath(languageFrom: languageFrom, languageTo: languageTo)) { [self] url, error in
            if let error = error {
                print("Error downloaded vocab for languages: \(languageFrom)-\(languageTo) from path: \(path), ", error)
                callback(false)
            } else {
                print("Successfully downloading vocab for languages: \(languageFrom)-\(languageTo) from path: \(path)")
                // update global Vocabs singleton with new version
                let vocab = Vocab.loadV2(languageFrom: languageFrom, languageTo: languageTo)
                if vocabs[languageFrom] == nil {
                    vocabs[languageFrom] = [:]
                }
                vocabs[languageFrom]![languageTo] = vocab
                print("Successfully updated vocab for languages: \(languageFrom)-\(languageTo) from path: \(path)")
                callback(true)
            }
        }
    }
}
