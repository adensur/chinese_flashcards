//
//  ExerciseView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 08/06/2023.
//

import SwiftUI
import Foundation

struct ExerciseView: View {
    @EnvironmentObject var decks: Decks
    @ObservedObject var deck: Deck
    @State var reveal = false
    @State var textInput = ""
    @FocusState var textInputFocus
    @Environment(\.dismiss) var dismiss
    init(deck: Deck) {
        self.deck = deck
    }
    var body: some View {
        VStack {
            ExerciseHeaderView(deck: deck){ // deck delete callback
                dismiss()
            }
            if let currentCard = deck.currentCard {
                if currentCard.isFrontSideUp {
                    FrontCardView(reveal: $reveal, card: currentCard, deck: deck)
                    if reveal {
                        RevealCardView(card: currentCard) {difficulty in
                            nextCard(currentCard: currentCard, difficulty: difficulty)
                        }
                    } else {
                        Spacer()
                        CardCountsView(cardCounts: deck.learnCounts)
                    }
                } else {
                    if deck.disableAllTextInputExercises || !currentCard.enableTextInputExercise {
                        BackCardView(reveal: $reveal, card: currentCard, deck: deck)
                        if reveal {
                            BackRevealCardView(card: currentCard, deck: deck) {difficulty in
                                nextCard(currentCard: currentCard, difficulty: difficulty)
                            }
                        }
                    } else {
                        BackWritingCardView(reveal: $reveal, textInput: $textInput, card: currentCard, deck: deck, focused: $textInputFocus)
                        if reveal {
                            BackWritingRevealCardView(card: currentCard, deck: deck, textInput: textInput) {difficulty in
                                nextCard(currentCard: currentCard, difficulty: difficulty)
                            }
                        }
                        Spacer()
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
        }
        .animation(.easeIn, value: reveal)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task {
                // trigger vocab loading in advance
                let _ = vocabs.getVocab(languageFrom: deck.deckMetadata.frontLanguage.rawValue, languageTo: deck.deckMetadata.backLanguage.rawValue)
            }
        }
    }
    
    func nextCard(currentCard: Card, difficulty: Difficulty) {
        reveal = false
        textInput = ""
        textInputFocus = true
        withAnimation {
            deck.consumeAnswer(difficulty: difficulty)
        }
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
