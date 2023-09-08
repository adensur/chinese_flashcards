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
    
    var currentExercise: EExerciseType? {
        guard let card = deck.currentCard else {
            return nil
        }
        if card.isFrontSideUp {
            return .frontToBack
        } else if deck.disableAllTextInputExercises || !card.enableTextInputExercise {
            return .backToFront
        } else {
            return .writing
        }
    }
    
    var body: some View {
        VStack {
            ExerciseHeaderView(deck: deck){ // deck delete callback
                dismiss()
            }
            if let currentCard = deck.currentCard {
                VStack {
                    Spacer()
                    switch currentExercise! {
                    case .frontToBack:
                        FrontCardView(card: currentCard, deck: deck)
                    case .backToFront:
                        BackCardView(card: currentCard, deck: deck)
                    case .writing:
                        BackWritingCardView(reveal: $reveal, textInput: $textInput, card: currentCard, deck: deck, focused: $textInputFocus)
                    }
                    if reveal {
                        switch currentExercise! {
                        case .frontToBack:
                            RevealCardView(card: currentCard, deck: deck)
                        case .backToFront:
                            BackRevealCardView(card: currentCard, deck: deck)
                        case .writing:
                            BackWritingRevealCardView(card: currentCard, deck: deck, textInput: textInput)
                        }
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    // do not accidentally reveal when writing
                    if currentExercise != .writing {
                        reveal = true
                    }
                }
                if reveal {
                    if deck.showAdvancedDifficultyButtons {
                        AdvancedDifficultyButtonsView(card: currentCard) {difficulty in
                            nextCard(currentCard: currentCard, difficulty: difficulty)
                        }
                    } else {
                        SimpleDifficultyButtonsView(card: currentCard) {difficulty in
                            nextCard(currentCard: currentCard, difficulty: difficulty)
                        }
                    }
                } else {
                    Button {
                        reveal = true
                    } label: {
                        Text("Reveal")
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .buttonStyle(.bordered)
                    CardCountsView(cardCounts: deck.learnCounts)
                }
            } else {
                if let nextDate = deck.nextRepetitionDate {
                    OutOfCardsView(nextDate: nextDate) {
                        deck.nextCard()
                    }
                } else {
                    Spacer()
                    Text("Ready to add a new card?")
                        .padding()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
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
