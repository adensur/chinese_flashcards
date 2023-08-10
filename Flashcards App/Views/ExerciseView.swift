//
//  ExerciseView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 08/06/2023.
//

import SwiftUI
import Foundation

struct ExerciseView: View {
    @ObservedObject var deck: Deck
    @State var reveal = false
    
    init(deck: Deck) {
        self.deck = deck
    }
    var body: some View {
        NavigationView {
            VStack {
                ExerciseHeaderView(deck: deck)
                if let currentCard = deck.currentCard {
                    if currentCard.isFrontSideUp {
                        FrontCardView(reveal: $reveal, card: currentCard, deck: deck)
                        if reveal {
                            RevealCardView(card: currentCard) {difficulty in
                                nextCard(currentCard: currentCard, difficulty: difficulty)
                            }
                        }
                    } else {
                        BackCardView(reveal: $reveal, card: currentCard, deck: deck)
                        if reveal {
                            BackRevealCardView(card: currentCard, deck: deck) {difficulty in
                                nextCard(currentCard: currentCard, difficulty: difficulty)
                            }
                        }
                    }
                } else {
                    if let nextDate = deck.nextRepetitionDate {
                        OutOfCardsView(nextDate: nextDate) {
                            deck.nextCard()
                        }
                    } else {
                        Text("No cards added yet!")
                        Spacer()
                    }
                }
            }.animation(.easeIn, value: reveal)
        }
    }
    
    func nextCard(currentCard: Card, difficulty: Difficulty) {
        reveal = false
        deck.consumeAnswer(difficulty: difficulty)
        if let card = deck.currentCard {
            if card.isFrontSideUp {
                card.playSound()
            }
        }
    }
}

struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseView(deck: previewDeck)
    }
}
