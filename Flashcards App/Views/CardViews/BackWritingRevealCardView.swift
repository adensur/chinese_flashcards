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
    var body: some View {
        VStack {
            Divider()
            if textInput == card.frontText {
                Text("You are correct!")
                    .font(.largeTitle)
                Text(card.frontText)
                    .font(.largeTitle)
                    .background(Color.green)
                
            } else {
                Text("Incorrect")
                    .font(.largeTitle)
                CorrectedTextView(text: textInput, correctText: card.frontText)
            }
            if let data = card.audioData {
                PlaySoundButton(audioData: data) {
                    Image(systemName: "play")
                        .imageScale(.large)
                }
            }
        }.onAppear {
            if let currentCard = deck.currentCard {
                currentCard.playSound()
            }
        }
    }
}

struct BackWritingRevealCardView_Previews: PreviewProvider {
    static var previews: some View {
        BackWritingRevealCardView(card: previewDeck.cards[0], deck: previewDeck, textInput: "asd")
    }
}
