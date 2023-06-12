//
//  Deck.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 08/06/2023.
//

import Foundation

class Deck: Encodable, Decodable {
    var cards: [Card] = []
    var currentIdx = -1
    
    init(cards: [Card]) {
        self.cards = cards
    }
    
    func nextCard() -> Card? {
        if cards.isEmpty {
            return nil
        }
        // circle from next card in the deck until the current card, inclusive, until we find something ready to review
        // this might show current card again!
        for idx in currentIdx + 1 ... currentIdx + cards.count {
            let i = idx % cards.count
            if cards[i].isReady() {
                currentIdx = i
                return cards[i]
            }
        }
        return nil
    }
    
    func deleteCurrentCard() {
        cards.remove(at: currentIdx)
    }
    
    func save() {
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(self)

        // Write the JSON data to a file
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("data.json")
        try! jsonData.write(to: fileURL)
    }
}

var defaultDeck = load()

func load() -> Deck {
    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("data.json")
    if let jsonData = try? Data(contentsOf: fileURL) {
        // Decode the JSON data into the structure
        let decoder = JSONDecoder()
        let deck = try! decoder.decode(Deck.self, from: jsonData)
        return deck
    } else {
        return Deck(cards: [])
    }
}

enum Difficulty {
case Again
case Hard
case Good
case Easy
}
