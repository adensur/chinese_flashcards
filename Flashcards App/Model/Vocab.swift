//
//  Vocab.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 17/07/2023.
//

import Foundation
import Zip

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

class Vocab {
    var cards: [String: VocabCard] = [:]
    init(cards: [VocabCard]) {
        for card in cards {
            self.cards[card.frontText] = card
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
