//
//  Deck.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 08/06/2023.
//

import Foundation
import DequeModule

class Deck: Codable, ObservableObject {
    // Main information about all cards and repetitions
    @Published var cards: [Card] = []
    // Updated each time nextCard is called
    // Persisted through app restarts
    @Published private var currentIdx: Int? = nil
    // Updated each time nextCard is called
    @Published private(set) var nextRepetitionDate: Date? = nil
    // Option
    // Whether or not next card will always be deterministic, by date added, or random
    @Published var shuffle: Bool = false {
        didSet {
            save()
        }
    }
    // global counter used to generate unique id to every added card
    var maxId = 0
    // non-persistent data
    // contains up to 5 last cards, to do advanced shuffling to avoid repetitions
    var lastCards: Deque<Card> = []
    
    var currentCard: Card? {
        if let idx = currentIdx {
            return self.cards[idx]
        } else {
            return nil
        }
    }
    // instantly make cards with up to this time interval "trainable"
    private static let minTimeInterval = TimeInterval(20 * 60) // 20 minutes
    
    init(cards: [Card]) {
        self.cards = cards
    }
    
    enum CodingKeys: CodingKey {
        case cards, currentIdx, shuffle, maxId
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cards, forKey: .cards)
        try container.encode(currentIdx, forKey: .currentIdx)
        try container.encode(shuffle, forKey: .shuffle)
        try container.encode(maxId, forKey: .maxId)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cards = try container.decode([Card].self, forKey: .cards)
        maxId = try container.decode(Int.self, forKey: .maxId)
        currentIdx = try? container.decode((Int?).self, forKey: .currentIdx)
        if let idx = currentIdx {
            nextRepetitionDate = cards[idx].getNextRepetition()
        } else {
            nextCard()
        }
        if let shuffle = try? container.decode(Bool.self, forKey: .shuffle) {
            self.shuffle = shuffle
        }
    }
    
    func addCard(frontText: String, backText: String, audioData: Data? = nil) {
        self.cards.append(Card(frontText: frontText, backText: backText, id: maxId, creationDate: Date(), audioData: audioData))
        maxId += 1
        // we had no card before, but now we have a card. Need to trigger the repetition update
        if currentIdx == nil {
            self.nextCard()
        } else {
            self.save()
        }
    }
    
    func nextCard() {
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
        // Learning and recently mistaken cards have priority
        var availableLearningCards: [Int] = []
        // other cards
        var availableOtherCards: [Int] = []
        for idx in startIdx + 1 ... startIdx + cards.count {
            let i = idx % cards.count
            let card = self.cards[i]
            let nextRepetition = card.getNextRepetition()
            if nextRepetition.addingTimeInterval(-Self.minTimeInterval) <= now {
                if !shuffle {
                    currentIdx = i
                    nextRepetitionDate = nextRepetition
                    return
                }
                switch card.learningStage {
                case .RepeatingAfterMistake(_), .Learning:
                    availableLearningCards.append(i)
                default:
                    availableOtherCards.append(i)
                }
            }
            if nextRepetition < minNextRepetition {
                minNextRepetition = nextRepetition
            }
        }
        if availableOtherCards.isEmpty && availableLearningCards.isEmpty {
            // out of cards-to-review
            currentIdx = nil
            nextRepetitionDate = minNextRepetition
            return
        }
        // First, try to show random learning cards, if they weren't present in the last 5 repetitions
        let recentlySeenCards = Set(lastCards)
        var newAvailableLearningCards: [Int] = []
        for idx in availableLearningCards {
            let card = cards[idx]
            if !recentlySeenCards.contains(card) {
                newAvailableLearningCards.append(idx)
            }
        }
        if !newAvailableLearningCards.isEmpty {
            newAvailableLearningCards.shuffle()
            currentIdx = newAvailableLearningCards.first
            nextRepetitionDate = cards[currentIdx!].getNextRepetition()
            return
        }
        // no learning cards that we haven't seen - try to get other cards
        var newAvailableOtherCards: [Int] = []
        for idx in availableOtherCards {
            let card = cards[idx]
            if !recentlySeenCards.contains(card) {
                newAvailableOtherCards.append(idx)
            }
        }
        if !newAvailableOtherCards.isEmpty {
            newAvailableOtherCards.shuffle()
            currentIdx = newAvailableOtherCards.first
            nextRepetitionDate = cards[currentIdx!].getNextRepetition()
        }
        // no unseen cards - let's show at least something!
        availableOtherCards.append(contentsOf: availableLearningCards)
        availableOtherCards.shuffle()
        currentIdx = availableOtherCards.first
        nextRepetitionDate = cards[currentIdx!].getNextRepetition()
    }
    
    func consumeAnswer(difficulty: Difficulty) {
        if let card = self.currentCard {
            self.currentCard!.consumeAnswer(difficulty: difficulty)
            self.lastCards.append(card)
            if self.lastCards.count > 5 {
                let _ = self.lastCards.popFirst()
            }
        } else {
            print("Unexpected error in consume answer - currentCard is nil!")
        }
        self.nextCard()
    }
    
    func deleteCard(id: Int) {
        cards.removeAll {card in
            card.id == id
        }
        if self.cards.isEmpty {
            currentIdx = nil
            nextRepetitionDate = nil
            self.save()
            return
        }
        if let idx = currentIdx {
            // currentIdx now points to the next card, unless current card was last
            // we have to "wrap it around" the array
            currentIdx = idx % cards.count
        }
        self.nextCard()
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
//    let fileURL = Bundle.main.url(forResource: "data", withExtension: "json")!
    if let jsonData = try? Data(contentsOf: fileURL) {
        print(fileURL)
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
    deck.nextCard()
    return deck
}

enum Difficulty: String, CaseIterable {
case Again
case Hard
case Good
case Easy
}
