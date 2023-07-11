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
    @State var nextInterval: TimeInterval = 0
    @State var isLoading = true
    @State var reveal = false
    
    // timer to do periodic refreshes when the user doesn't do anything
    let timer = Timer.publish(every: 1, tolerance: 0.5, on: .main, in: .common).autoconnect()
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
                    self.nextInterval = self.nextDate.timeIntervalSinceNow
                    isLoading = false
                }
                if let currentCard = currentCard {
                    FrontCardView(reveal: $reveal, card: currentCard)
                    if reveal {
                        VStack {
                            Divider()
                            Text(currentCard.backText)
                            Spacer()
                            HStack {
                                Spacer()
                                Button("\(currentCard.getNextRepetitionTooltip(difficulty:.Again))\nAgain") {
                                    nextCard(currentCard: currentCard, difficulty: .Again)
                                }
                                Spacer()
                                Button("\(currentCard.getNextRepetitionTooltip(difficulty:.Hard))\nHard") {
                                    nextCard(currentCard: currentCard, difficulty: .Hard)
                                }
                                Spacer()
                                Button("\(currentCard.getNextRepetitionTooltip(difficulty:.Good))\nGood") {
                                    nextCard(currentCard: currentCard, difficulty: .Good)
                                }
                                Spacer()
                                Button("\(currentCard.getNextRepetitionTooltip(difficulty:.Easy))\nEasy") {
                                    nextCard(currentCard: currentCard, difficulty: .Easy)
                                }
                                Spacer()
                            }
                        }
                    }
                } else {
                    Spacer()
                    Text("Out of cards for now! Next repetition in: \(encodeTimeInterval(timeInterval: self.nextInterval))")
                        .onReceive(timer) { _ in
                            self.nextInterval = self.nextDate.timeIntervalSinceNow
                            if self.nextInterval < 0 {
                                (self.currentCard, self.nextDate) = deck.nextCardAndDate()
                            }
                        }
                    Spacer()
                }
            }.animation(.easeIn, value: reveal)
        }
    }
    
    func nextCard(currentCard: Card, difficulty: Difficulty) {
        reveal = false
        currentCard.consumeAnswer(difficulty: difficulty)
        (self.currentCard, self.nextDate) = deck.nextCardAndDate()
        self.nextInterval = self.nextDate.timeIntervalSinceNow
        deck.save()
    }
}

struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseView(deck: previewDeck)
    }
}
