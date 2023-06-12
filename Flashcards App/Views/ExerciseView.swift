//
//  ExerciseView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 08/06/2023.
//

import SwiftUI

struct ExerciseView: View {
    var deck: Deck
    @State var currentCard: Card? = nil
    @State var isLoading = true
    @State var reveal = false
    init(deck: Deck) {
        self.deck = deck
    }
    var body: some View {
        Group {
            if isLoading {
                Text("").onAppear {
                    currentCard = deck.nextCard()
                    isLoading = false
                }
            } else {
                if let currentCard = currentCard {
                    Text(currentCard.frontText)
                        .onTapGesture {
                            reveal = true
                        }
                    Spacer()
                    if reveal {
                        VStack {
                            Divider()
                            Text(currentCard.backText)
                            Spacer()
                            HStack {
                                Button("Again") {
                                    nextCard(currentCard: currentCard, difficulty: .Again)
                                }
                                Button("Hard") {
                                    nextCard(currentCard: currentCard, difficulty: .Hard)
                                }
                                Button("Good") {
                                    nextCard(currentCard: currentCard, difficulty: .Good)
                                }
                                Button("Easy") {
                                    nextCard(currentCard: currentCard, difficulty: .Easy)
                                }
                                
                            }
                        }
                    }
                } else {
                    Text("Out of cards for now!")
                }
            }
        }.animation(.easeIn, value: reveal)
    }
    
    func nextCard(currentCard: Card, difficulty: Difficulty) {
        reveal = false
        currentCard.consumeAnswer(difficulty: difficulty)
        self.currentCard = deck.nextCard()
    }
}

struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseView(deck: defaultDeck)
    }
}
