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
            let frontText = String(values[0])
            let backText = String(values[1])
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
    
    let fileURL = Bundle.main.url(forResource: "hindipod_2k", withExtension: "tsv")!
    print("Bundle path: ", fileURL)
//    let content = try! String(contentsOf: fileURL)
//    let lines = content.split(separator: "\n")
//    // split the header of lines
//    for line in lines.dropFirst(1) {
//        let values = line.split(separator: "\t")
//        let frontText = String(values[0])
//        let backText = String(values[1])
//        vocab.cards[frontText] = VocabCard(frontText: frontText, backText: backText)
//    }
//    let vocab = Vocab(cards: [
////        .init(frontText: "a", backText: "b"),
////        .init(frontText: "ab", backText: "bb"),
////        .init(frontText: "abc", backText: "bbb"),
////        .init(frontText: "abcd", backText: "bbbb"),
////        .init(frontText: "abcde", backText: "bbbbb"),
////        .init(frontText: "abcdef", backText: "b12"),
////        .init(frontText: "abcdefg", backText: "b13"),
////        VocabCard(frontText:"आ", backText: "a"),
////        VocabCard(frontText:"आआ", backText: "aa"),
////        VocabCard(frontText:"आआआ", backText: "aaa"),
////        VocabCard(frontText:"आआआआ", backText: "aaaa"),
////        VocabCard(frontText:"आआआआआ", backText: "aaaaa"),
//        .init(frontText: "आगे", backText: "ahead"),
//        .init(frontText: "पीछे", backText: "behind"),
//        .init(frontText: "पनीर", backText: "cheese"),
//        .init(frontText: "पुरुष", backText: "man"),
//        .init(frontText: "स्त्री", backText: "woman"),
//        .init(frontText: "अनुमति", backText: "permission"),
//        .init(frontText: "लिए", backText: "for"),
//        .init(frontText: "शेष", backText: "remaining"),
//        .init(frontText: "तस्वीर", backText: "photo"),
//        .init(frontText: "उपयोग", backText: "utilisation"),
//        .init(frontText: "दिखाना", backText: "to show"),
//        .init(frontText: "वर्ष", backText: "year"),
//        .init(frontText: "छोड़ना", backText: "to leave"),
//        .init(frontText: "उम्र", backText: "age"),
//        .init(frontText: "चौदह", backText: "fourteen (14)"),
//        .init(frontText: "दिखाना", backText: "to show"),
//        .init(frontText: "लक्ष्य", backText: "the goal"),
//        .init(frontText: "समीक्षा", backText: "review"),
//        .init(frontText: "चालीस", backText: "forty (40)"),
//        .init(frontText: "चश्मा", backText: "glasses"),
//        .init(frontText: "ख़राब", backText: "bad"),
//    ])
    return vocab
}

let defaultVocab: Vocab = load()
