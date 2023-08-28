//
//  BackRevealCardView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 10/08/2023.
//

import SwiftUI

struct BackRevealCardView: View {
    @ObservedObject var card: Card
    @ObservedObject var deck: Deck
    var callback: (_: Difficulty) -> Void
    var body: some View {
        VStack {
            Divider()
            Text(card.frontText)
                .font(.largeTitle)
                .onAppear {
                    if let currentCard = deck.currentCard {
                        currentCard.playSound()
                    }
                }
            if let data = card.audioData {
                PlaySoundButton(audioData: data) {
                    Image(systemName: "play")
                        .imageScale(.large)
                }
            }
            Spacer()
            HStack {
                ForEach(Difficulty.allCases, id: \.self) {difficulty in
                    Spacer()
                    Button("\(card.getNextRepetitionTooltip(difficulty: difficulty))\n\(difficulty.rawValue)") {
                        callback(difficulty)
                    }
                }
                Spacer()
            }
        }
    }
}

struct BackRevealCardView_Previews: PreviewProvider {
    static var previews: some View {
        BackRevealCardView(card: previewDeck.cards[0], deck: previewDeck) {_ in
        }
    }
}
