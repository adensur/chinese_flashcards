//
//  Decks.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 20/08/2023.
//

import Foundation

class Decks: ObservableObject, Codable {
    @Published private(set) var decks: [DeckMetadata]
    init() {
        decks = []
    }
    enum CodingKeys: CodingKey {
        case decks
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(decks, forKey: .decks)
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        decks = try container.decode([DeckMetadata].self, forKey: .decks)
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
    
    func addDeck(_ deckMetadata: DeckMetadata) {
        decks.append(deckMetadata)
        // trigger async vocab update as well
        vocabUpdater.updateVocabs(decks: decks)
        save()
    }
}

