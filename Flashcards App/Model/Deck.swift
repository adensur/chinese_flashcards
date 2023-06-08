//
//  Deck.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 08/06/2023.
//

import Foundation

class Deck {
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
}

var defaultDeck = load()

func load() -> Deck {
    var cards: [Card] = []
    cards.append(Card(FrontText: "ऊपर", BackText: "up"))
    cards.append(Card(FrontText: "आगे", BackText: "ahead"))
    cards.append(Card(FrontText: "पीछे", BackText: "behind"))
    return Deck(cards: cards)
}

enum Difficulty {
case Again
case Hard
case Good
case Easy
}
