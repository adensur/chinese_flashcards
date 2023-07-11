//
//  ExerciseView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 08/06/2023.
//

import SwiftUI
import Foundation

struct ExerciseView: View {
    var deck: Deck
    @State var currentCard: Card? = nil
    @State var nextDate = Date()
    @State private var isLoading = true
    @State var reveal = false
    
    init(deck: Deck) {
        self.deck = deck
    }
    var body: some View {
        NavigationView {
            VStack {
                GroupBox {
                    HStack {
                        Spacer()
                        if let currentCard = currentCard {
                            NavigationLink {
                                EditCardView(card: currentCard)
                            } label: {
                                Text("edit")
                            }
                        }
                        NavigationLink {
                            AddCardView()
                        } label: {
                            Text("add")
                        }
                    }
                }.onAppear {
                    (currentCard, nextDate) = deck.nextCardAndDate()
                    isLoading = false
                }
                if let currentCard = currentCard {
                    FrontCardView(reveal: $reveal, card: currentCard)
                    if reveal {
                        RevealCardView(card: currentCard) {difficulty in
                            nextCard(currentCard: currentCard, difficulty: difficulty)
                        }
                    }
                } else {
                    OutOfCardsView(nextDate: nextDate) {
                        (self.currentCard, self.nextDate) = deck.nextCardAndDate()
                    }
                }
            }.animation(.easeIn, value: reveal)
        }
    }
    
    func nextCard(currentCard: Card, difficulty: Difficulty) {
        reveal = false
        currentCard.consumeAnswer(difficulty: difficulty)
        (self.currentCard, self.nextDate) = deck.nextCardAndDate()
        deck.save()
    }
}

struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseView(deck: previewDeck)
    }
}
