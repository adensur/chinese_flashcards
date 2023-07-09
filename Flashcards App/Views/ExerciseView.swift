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
                    currentCard = deck.nextCard()
                    isLoading = false
                }
                if let currentCard = currentCard {
                    VStack {
                        HStack{
                            Spacer()
                            Text(currentCard.frontText)
                            Spacer()
                        }
                        Spacer()
                    } .contentShape(Rectangle())
                    .onTapGesture {
                        reveal = true
                    }
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
                    Spacer()
                    Text("Out of cards for now!")
                    Spacer()
                }
            }.animation(.easeIn, value: reveal)
        }
    }
    
    func nextCard(currentCard: Card, difficulty: Difficulty) {
        reveal = false
        currentCard.consumeAnswer(difficulty: difficulty)
        self.currentCard = deck.nextCard()
        deck.save()
    }
}

struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseView(deck: previewDeck)
    }
}
