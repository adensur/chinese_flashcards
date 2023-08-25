//
//  Decks.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 20/08/2023.
//

import Foundation

class Decks: ObservableObject, Codable {
    @Published var vocabVersions: [VocabMetadata] = []
    @Published var decks: [DeckMetadata]
    init() {
        decks = []
    }
    enum CodingKeys: CodingKey {
        case decks, vocabVersions
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(decks, forKey: .decks)
        try container.encode(vocabVersions, forKey: .vocabVersions)
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        decks = try container.decode([DeckMetadata].self, forKey: .decks)
        if let vocabs = try? container.decode([VocabMetadata].self, forKey: .vocabVersions) {
            vocabVersions = vocabs
        }
    }
    static func load() -> Decks {
        do {
            if let jsonData = try? Data(contentsOf: getMetadataUrl()) {
                let decoder = JSONDecoder()
                let decks = try decoder.decode(Decks.self, from: jsonData)
                return decks
            }
        } catch {
            print("Failed loading decks...")
        }
        return Decks()
    }
    static func previewLoad() -> Decks {
        return Decks()
    }
    func save() {
        print("saving decks metadata!", Date())
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(self)

        // Write the JSON data to a file
        let fileURL = Self.getMetadataUrl()
        try! jsonData.write(to: fileURL)
    }
    
    static private func getMetadataUrl() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("deck_metadata.json")
    }
    
    func deleteDecks(atOffsets: IndexSet) {
        for idx in atOffsets {
            let deck = decks[idx]
            do {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentsDirectory.appendingPathComponent(deck.savePath)
                try FileManager.default.removeItem(at: fileURL)
                print("File deleted successfully")
            } catch {
                print("Error deleting file: \(error)")
            }
        }
        decks.remove(atOffsets: atOffsets)
        save()
    }
    
    func deleteDeck(deck: Deck) {
        // remove all decks by savedPath - unique identifier
        decks.removeAll {deckMetadata in
            deckMetadata.savePath == deck.deckMetadata.savePath
        }
        // remove the file
        do {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(deck.deckMetadata.savePath)
            try FileManager.default.removeItem(at: fileURL)
            print("File deleted successfully")
        } catch {
            print("Error deleting file: \(error)")
        }
        save()
    }
    
    func updateVocabs(newVocabMetadata: [VocabMetadata]) {
        for newVocabVersion in newVocabMetadata {
            let m = decks.first {deck in
                deck.frontLanguage.rawValue == newVocabVersion.languageFrom && deck.backLanguage.rawValue == newVocabVersion.languageTo
            }
            if m == nil {
                // no decks with this language pair
                continue
            }
            let v = vocabVersions.first {vocabVersion in
                newVocabVersion.languageTo == vocabVersion.languageTo && newVocabVersion.languageFrom == vocabVersion.languageFrom
            }
            if let vocabVersion = v {
                if vocabVersion.version == newVocabVersion.version {
                    // already updated to this version
                    print("Skipping updating vocabs for \(newVocabMetadata), already up to date")
                    continue
                }
            }
            // no previous versions of this vocab, or current version is old
            vocabs.updateVocab(languageFrom: newVocabVersion.languageFrom, languageTo: newVocabVersion.languageTo, path: newVocabVersion.path) { [self]isSuccess in
                if isSuccess {
                    // update vocab metadata and save
                    let serialQueue = DispatchQueue(label: "queuename")
                    serialQueue.sync {
                        self.vocabVersions.removeAll {vocabVersion in
                            newVocabVersion.languageTo == vocabVersion.languageTo && newVocabVersion.languageFrom == vocabVersion.languageFrom
                        }
                        self.vocabVersions.append(newVocabVersion)
                        save()
                    }
                }
            }
        }
    }
}

