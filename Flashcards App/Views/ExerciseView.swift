//
//  ExerciseView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 08/06/2023.
//

import SwiftUI
import Foundation
import HanziWriter

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
    
    // vars for onboarding spotlight
    @State private var showSpotlight = false
    @State private var currentSpot = 0
    
    var currentExercise: EExerciseType? {
        guard let card = deck.currentCard else {
            return nil
        }
        switch card.cardState {
        case .simple(let eSimpleCardState):
            if eSimpleCardState == .frontSideUp {
                return .frontToBack
            } else if deck.disableAllTextInputExercises || !card.enableTextInputExercise {
                return .backToFront
            } else {
                return .writing
            }
        case .japanese(let eJapaneseCardState):
            switch eJapaneseCardState {
            case .kanjiToKana:
                if deck.disableAllTextInputExercises || !card.enableTextInputExercise {
                    return .backToFront
                } else {
                    return .kanaWriting
                }
            case .kanjiToTranslation:
                return .kanjiToTranslation
            case .kanaToKanji:
                return .scribbling
            case .translationToKanji:
                return .scribbling
            case .kanaToTranslation:
                return .kanaToTranslation
            case .translationToKana:
                return .translationToKana
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ExerciseHeaderView(deck: deck){
                    // this is deck delete callback
                    // dismisses parent view (of the deleted deck)
                    dismiss()
                }
                if let currentCard = deck.currentCard {
                    VStack {
                        Spacer(minLength: geometry.size.height / 6)
                        VStack {
                            switch currentExercise! {
                            case .frontToBack:
                                FrontCardView(card: currentCard, deck: deck)
                            case .backToFront:
                                BackCardView(card: currentCard, deck: deck)
                            case .writing:
                                BackWritingCardView(reveal: $reveal, textInput: $textInput, card: currentCard, deck: deck, focused: $textInputFocus)
                            case .kanaWriting:
                                KanaWritingCardView(reveal: $reveal, textInput: $textInput, card: currentCard, deck: deck, focused: $textInputFocus)
                            case .scribbling:
                                if !reveal {
                                    ScribblingExerciseView(language: deck.deckMetadata.frontLanguage, card: currentCard) {
                                        reveal = true
                                    }
                                }
                            case .kanjiToTranslation:
                                KanjiToTranslationView(card: currentCard, deck: deck)
                            case .kanaToTranslation:
                                KanaToTranslationView(card: currentCard, deck: deck)
                            case .translationToKana:
                                if !reveal {
                                    ScribblingExerciseView(language: deck.deckMetadata.frontLanguage, card: currentCard) {
                                        reveal = true
                                    }
                                }
                            }
                            if reveal {
                                switch currentExercise! {
                                case .frontToBack:
                                    RevealCardView(card: currentCard, deck: deck)
                                case .backToFront:
                                    BackRevealCardView(card: currentCard, deck: deck)
                                case .writing:
                                    BackWritingRevealCardView(card: currentCard, deck: deck, textInput: textInput)
                                case .kanaWriting:
                                    KanaWritingRevealCardView(card: currentCard, deck: deck, textInput: textInput)
                                case .scribbling:
                                    ScribblingRevealExerciseView(language: deck.deckMetadata.frontLanguage, card: currentCard)
                                case .kanjiToTranslation:
                                    KanjiToTranslationRevealView(card: currentCard, deck: deck)
                                case .kanaToTranslation:
                                    KanaToTranslationRevealView(card: currentCard, deck: deck)
                                case .translationToKana:
                                    ScribblingRevealExerciseView(language: deck.deckMetadata.frontLanguage, card: currentCard)
                                }
                            }
                        }
                        .frame(minHeight: geometry.size.height / 6, alignment: .top)
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
                        Group {
                            if deck.showAdvancedDifficultyButtons {
                                AdvancedDifficultyButtonsView(card: currentCard) {difficulty in
                                    nextCard(currentCard: currentCard, difficulty: difficulty)
                                }
                            } else {
                                SimpleDifficultyButtonsView(card: currentCard) {difficulty in
                                    nextCard(currentCard: currentCard, difficulty: difficulty)
                                }
                            }
                        }.addSpotlight(2, shape: .rounded, roundedRadius: 10, text: "If you are happy with your guess, press 👍. Otherwise, press 👎")
                    } else {
                        Button {
                            reveal = true
                        } label: {
                            Text("Reveal")
                                .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .buttonStyle(.bordered)
                        .addSpotlight(1, shape: .rounded, roundedRadius: 10, text: "Press \"reveal\", or anywhere at the bottom of the screen, once you are ready")
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
            .navigationBarBackButtonHidden(true)
            .onAppear {
                Task {
                    // trigger vocab loading in advance
                    let _ = vocabs.getVocab(languageFrom: deck.deckMetadata.frontLanguage.rawValue, languageTo: deck.deckMetadata.backLanguage.rawValue)
                }
            }
        }
        .ignoresSafeArea([.keyboard])
//        .addSpotlightOverlay(show: $showSpotlight, currentSpot: $currentSpot)
        .onAppear {
            showSpotlight = true
        }
    }
    
    func nextCard(currentCard: Card, difficulty: Difficulty) {
        reveal = false
        textInput = ""
        textInputFocus = true
        deck.consumeAnswer(difficulty: difficulty)
        if let card = deck.currentCard {
            if card.shouldPlaySoundOnAppear() {
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
