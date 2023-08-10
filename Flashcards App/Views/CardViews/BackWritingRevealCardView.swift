//
//  BackWritingRevealCardView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 10/08/2023.
//

import SwiftUI

struct BackWritingRevealCardView: View {
    @ObservedObject var card: Card
    @ObservedObject var deck: Deck
    var textInput: String
    var callback: (_: Difficulty) -> Void
    var body: some View {
        VStack {
            Divider()
            if textInput == card.frontText {
                Text("You are correct!")
                Text(card.frontText)
                    .background(Color.green)
                    .onAppear {
                        if let currentCard = deck.currentCard {
                            currentCard.playSound()
                        }
                    }
            } else {
                Text("Incorrect")
                Text(textInput)
                    .background(Color.red)
                Image(systemName: "arrow.down")
                Text(card.frontText)
                    .background(Color.green)
            }
            if let data = card.audioData {
                PlaySoundButton(audioData: data) {
                    Image(systemName: "play")
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

#Preview {
    BackWritingRevealCardView(card: previewDeck.cards[0], deck: previewDeck, textInput: "asd") {_ in
    }
}
