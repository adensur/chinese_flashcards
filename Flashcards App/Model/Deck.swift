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
    @Published var shuffle: Bool = true {
        didSet {
            if shuffle != oldValue {
                save()
            }
        }
    }
    // Option
    // Disables all writing exercises for all cards, despite card options
    @Published var disableAllTextInputExercises: Bool = false {
        didSet {
            if disableAllTextInputExercises != oldValue {
                save()
            }
        }
    }
    // Option
    // Disables sound
    @Published var disableSound: Bool = false {
        didSet {
            if disableSound != oldValue {
                save()
            }
        }
    }
    @Published var deckMetadata: DeckMetadata
    @Published var showAdvancedDifficultyButtons: Bool = false {
        didSet {
            if showAdvancedDifficultyButtons != oldValue {
                save()
            }
        }
    }
    // global counter used to generate unique id to every added card
    var maxId = 0
    // the card will not be repeated if it was repeated in the last maxLastCards repetitions
    static let maxLastCards = 2
    // maximum number of cards currently being learned (all levels)
    static let maxLearningCards = 10
    // number of repeating cards to add to every batch
    static let learnedCardsInBatch = 4
    // instantly make cards with up to this time interval "trainable"
    static let minTimeInterval = TimeInterval(20 * 60) // 20 minutes
    // non-persistent data
    // contains up to maxLastCards last cards, to do advanced shuffling to avoid repetitions
    var lastCards: Deque<Card> = []
    
    var currentCard: Card? {
        if let idx = currentIdx {
            return self.cards[idx]
        } else {
            return nil
        }
    }
    
    // card counts: new cards, cards being learned, cards being repeated
    var learnCounts: CardCounts {
        var new = 0
        var repeating = 0
        var learning = 0
        for card in cards {
            if card.getNextRepetition().addingTimeInterval(-Self.minTimeInterval) > Date() {
                continue
            }
            switch card.learningStage {
            case .New:
                new += 1
            case .Learning(_), .RepeatingAfterMistake(_):
                learning += 1
            case .Repeating(_):
                repeating += 1
            default:
                ()
            }
        }
        return CardCounts(new: new, repeating: repeating, learning: learning)
    }
    
    init(cards: [Card], deckMetadata: DeckMetadata) {
        self.cards = cards
        self.deckMetadata = deckMetadata
    }
    
    enum CodingKeys: CodingKey {
        case cards, currentIdx, shuffle, maxId, disableAllTextInputExercises, deckMetadata, showAdvancedDifficultyButtons
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cards, forKey: .cards)
        try container.encode(currentIdx, forKey: .currentIdx)
        try container.encode(shuffle, forKey: .shuffle)
        try container.encode(maxId, forKey: .maxId)
        try container.encode(disableAllTextInputExercises, forKey: .disableAllTextInputExercises)
        try container.encode(deckMetadata, forKey: .deckMetadata)
        try container.encode(showAdvancedDifficultyButtons, forKey: .showAdvancedDifficultyButtons)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cards = try container.decode([Card].self, forKey: .cards)
        maxId = try container.decode(Int.self, forKey: .maxId)
        currentIdx = try? container.decode((Int?).self, forKey: .currentIdx)
        deckMetadata = try container.decode(DeckMetadata.self, forKey: .deckMetadata)
        if let idx = currentIdx {
            nextRepetitionDate = cards[idx].getNextRepetition()
        } else {
            nextCard()
        }
        shuffle = try container.decode(Bool.self, forKey: .shuffle)
        if let val = try? container.decode(Bool.self, forKey: .disableAllTextInputExercises) {
            disableAllTextInputExercises = val
        }
        showAdvancedDifficultyButtons = (try? container.decode(Bool.self, forKey: .showAdvancedDifficultyButtons)) ?? false
    }
    
    func addCard(frontText: String, backText: String, audioData: Data? = nil, enableTextInputExercise: Bool = true, wordType: EWordType = .unknown) {
        self.cards.append(Card(frontText: frontText, backText: backText, id: maxId, creationDate: Date(), audioData: audioData, enableTextInputExercise: enableTextInputExercise, type: wordType, deck: self))
        maxId += 1
        // we had no card before, but now we have a card. Need to trigger the repetition update
        if currentIdx == nil {
            self.nextCard()
        } else {
            // save is part of nextCard() call as well
            self.save()
        }
    }
    
    func addCard(card: Card) {
        card.id = maxId
        maxId += 1
        self.cards.append(card)
        if currentIdx == nil {
            self.nextCard()
        } else {
            // save is part of nextCard() call as well
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
        // top priority - learning cards with low level
        var availableFreshCards: [Int] = []
        // Learning and recently mistaken cards have priority
        var availableLearningCards: [Int] = []
        // new cards
        var availableNewCards: [Int] = []
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
                case .RepeatingAfterMistake(let lvl):
                    if lvl < 5 {
                        availableFreshCards.append(i)
                    } else {
                        availableLearningCards.append(i)
                    }
                case .Learning(let lvl):
                    if lvl < 5 {
                        availableFreshCards.append(i)
                    } else {
                        availableLearningCards.append(i)
                    }
                case .New:
                    availableNewCards.append(i)
                default:
                    availableOtherCards.append(i)
                }
            }
            if nextRepetition < minNextRepetition {
                minNextRepetition = nextRepetition
            }
        }
        if availableOtherCards.isEmpty && availableLearningCards.isEmpty && availableNewCards.isEmpty && availableFreshCards.isEmpty {
            // out of cards-to-review
            currentIdx = nil
            nextRepetitionDate = minNextRepetition
            return
        }
        // filter out learning, repeating and new cards by already seen cards
        let newAvailableFreshCards = availableFreshCards.filter {idx in
            return !lastCards.contains(cards[idx])
        }
        let newAvailableLearningCards = availableLearningCards.filter {idx in
            return !lastCards.contains(cards[idx])
        }
        let newAvailableNewCards = availableNewCards.filter {idx in
            return !lastCards.contains(cards[idx])
        }
        let newAvailableOtherCards = availableOtherCards.filter {idx in
            return !lastCards.contains(cards[idx])
        }
        // with 50% chance, just take a random fresh card
        if Int.random(in: 0..<2) == 0 {
            if let selectedIdx = newAvailableFreshCards.randomElement() {
                currentIdx = selectedIdx
                nextRepetitionDate = cards[currentIdx!].getNextRepetition()
                return
            }
        }
        var newAvailableCards = newAvailableLearningCards
        if newAvailableCards.count + newAvailableFreshCards.count < Self.maxLearningCards {
            // how many new cards to add
            let diff = Self.maxLearningCards - newAvailableCards.count
            let newCardsToTake = min(newAvailableNewCards.count, diff)
            let newCards = newAvailableNewCards.shuffled()[0..<newCardsToTake]
            newAvailableCards.append(contentsOf: newCards)
        }
        let otherCardsToTake = min(Self.learnedCardsInBatch, newAvailableOtherCards.count)
        let otherCards = newAvailableOtherCards.shuffled()[0..<otherCardsToTake]
        newAvailableCards.append(contentsOf: otherCards)
        // works if array is not empty
        if let idx = newAvailableCards.randomElement() {
            currentIdx = idx
            nextRepetitionDate = cards[currentIdx!].getNextRepetition()
            return
        }
        // no unseen cards - let's show at least something!
        // Just show next available card, no matter if its ready or not
        minNextRepetition = cards[0].getNextRepetition()
        var nextIdx = 0
        for idx in 0 ..< cards.count {
            let card = self.cards[idx]
            if lastCards.contains(card) {
                continue
            }
            let nextRepetition = card.getNextRepetition()
            if nextRepetition < minNextRepetition {
                minNextRepetition = nextRepetition
                nextIdx = idx
            }
        }
        currentIdx = nextIdx
        nextRepetitionDate = cards[currentIdx!].getNextRepetition()
    }
    
    func consumeAnswer(difficulty: Difficulty) {
        if let card = self.currentCard {
            self.currentCard!.consumeAnswer(difficulty: difficulty)
            self.lastCards.append(card)
            if self.lastCards.count > Self.maxLastCards {
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
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(self)

        // Write the JSON data to a file
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(deckMetadata.savePath)
        print("Saving \(deckMetadata.name) to \(fileURL)", Date())
        try! jsonData.write(to: fileURL)
    }
    
    static var loadedDecks: [String: Deck] = [:]
    
    static func load(deckMetadata: DeckMetadata) -> Deck {
        if let deck = loadedDecks[deckMetadata.savePath] {
            return deck
        } else {
            let deck = loadInner(deckMetadata: deckMetadata)
            let serialQueue = DispatchQueue(label: "deck")
            serialQueue.sync {
                loadedDecks[deckMetadata.savePath] = deck
            }
            return deck
        }
    }
    
    static private func loadInner(deckMetadata: DeckMetadata) -> Deck {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(deckMetadata.savePath)
        print("Loading \(deckMetadata.name) from \(fileURL)", Date())
        if let jsonData = try? Data(contentsOf: fileURL) {
            print(deckMetadata.savePath)
            let decoder = JSONDecoder()
            let deck = try! decoder.decode(Deck.self, from: jsonData)
            // set backlinks
            for card in deck.cards {
                card.deck = deck
            }
            deck.deckMetadata = deckMetadata
            return deck
        } else {
            return Deck(cards: [], deckMetadata: deckMetadata)
        }
    }
}

var previewDeck = simulatedLoad()

func simulatedLoad() -> Deck {
    let deck = Deck(cards: [], deckMetadata: DeckMetadata.getPreviewDeckMetadata())
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

class DeckMetadata: ObservableObject, Codable {
    @Published var name: String
    @Published var frontLanguage: ELanguage {
        didSet {
            if frontLanguage != oldValue {
                decks?.save()
            }
        }
    }
    @Published var backLanguage: ELanguage {
        didSet {
            if backLanguage != oldValue {
                decks?.save()
            }
        }
    }
    weak var decks: Decks?
    let savePath: String
    init(name: String, frontLanguage: ELanguage, backLanguage: ELanguage) {
        self.name = name
        self.frontLanguage = frontLanguage
        self.backLanguage = backLanguage
        // generating unique filename
        let uniqueFilename = UUID().uuidString + ".json"
        self.savePath = uniqueFilename
    }
    
    static func getPreviewDeckMetadata() -> DeckMetadata {
        return DeckMetadata(name: "hindi", frontLanguage: .Hindi, backLanguage: .English)
    }
    
    enum CodingKeys: CodingKey {
        case name, frontLanguage, backLanguage, savePath
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(frontLanguage.rawValue, forKey: .frontLanguage)
        try container.encode(backLanguage.rawValue, forKey: .backLanguage)
        try container.encode(savePath, forKey: .savePath)
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        frontLanguage = try ELanguage(rawValue: container.decode(String.self, forKey: .frontLanguage))!
        backLanguage = try ELanguage(rawValue: container.decode(String.self, forKey: .backLanguage))!
        savePath = try container.decode(String.self, forKey: .savePath)
    }
}
