//
//  Deck.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 08/06/2023.
//

import Foundation

class Deck: Codable, ObservableObject {
    @Published var cards: [Card] = []
    @Published var currentIdx: Int? = nil
    @Published var nextRepetitionDate: Date? = nil
    
    var currentCard: Card? {
        if let idx = currentIdx {
            return self.cards[idx]
        } else {
            return nil
        }
    }
    // instantly make cards with up to this time interval "trainable"
    private static let minTimeInterval = TimeInterval(20 * 60) // 20 minutes
    
    // global counter used to generate unique id to every added card
    var maxId = 0
    
    init(cards: [Card]) {
        self.cards = cards
    }
    
    enum CodingKeys: CodingKey {
        case cards, currentIdx
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cards, forKey: .cards)
        try container.encode(currentIdx, forKey: .currentIdx)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cards = try container.decode([Card].self, forKey: .cards)
        currentIdx = try container.decode((Int?).self, forKey: .currentIdx)
        if let idx = currentIdx {
            nextRepetitionDate = cards[idx].getNextRepetition()
        } else {
            nextCardAndDate()
        }
    }
    
    func addCard(frontText: String, backText: String, audioData: Data? = nil) {
        self.cards.append(Card(frontText: frontText, backText: backText, id: maxId, creationDate: Date(), audioData: audioData))
        maxId += 1
        // we had no card before, but now we have a card. Need to trigger the repetition update
        if currentIdx == nil {
            self.nextCardAndDate()
        } else {
            self.save()
        }
    }
    
    func nextCardAndDate() {
        if cards.isEmpty {
            return
        }
        defer {
            self.save()
        }
        // circle from next card in the deck until the current card, inclusive, until we find something ready to review
        // this might show current card again!
        let now = Date()
        var minNextRepetition = cards[0].getNextRepetition()
        let startIdx: Int
        if let idx = currentIdx {
            startIdx = idx
        } else {
            startIdx = -1
        }
        for idx in startIdx + 1 ... startIdx + cards.count {
            let i = idx % cards.count
            let nextRepetition = cards[i].getNextRepetition()
            if nextRepetition.addingTimeInterval(-Self.minTimeInterval) <= now {
                currentIdx = i
                nextRepetitionDate = nextRepetition
                return
            }
            if nextRepetition < minNextRepetition {
                minNextRepetition = nextRepetition
            }
        }
        // out of cards-to-review
        currentIdx = nil
        nextRepetitionDate = minNextRepetition
    }
    
    func consumeAnswer(difficulty: Difficulty) {
        self.currentCard!.consumeAnswer(difficulty: difficulty)
        self.nextCardAndDate()
    }
    
    func deleteCurrentCard() {
        let idx = currentIdx!
        cards.remove(at: idx)
        if self.cards.isEmpty {
            currentIdx = nil
            nextRepetitionDate = nil
            self.save()
            return
        }
        // currentIdx now points to the next card, unless current card was last
        // we have to "wrap it around" the array
        currentIdx = idx % cards.count
        self.nextCardAndDate()
    }
    
    func save() {
        print("saving deck!", Date())
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(self)

        // Write the JSON data to a file
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("data.json")
        try! jsonData.write(to: fileURL)
    }
}

var defaultDeck: Deck = load()

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

var previewDeck = simulatedLoad()

func simulatedLoad() -> Deck {
    let deck = Deck(cards: [])
    deck.addCard(frontText: "आगे", backText: "ahead")
    deck.addCard(frontText: "पीछे", backText: "behind")
    deck.nextCardAndDate()
    return deck
}

enum Difficulty: String, CaseIterable {
case Again
case Hard
case Good
case Easy
}
