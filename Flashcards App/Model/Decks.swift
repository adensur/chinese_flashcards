//
//  Decks.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 20/08/2023.
//

import Foundation

class Decks: ObservableObject, Codable {
    @Published var decks: [DeckMetadata]
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
}
