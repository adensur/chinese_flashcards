//
//  KanaWritingRevealCardView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 14/11/2023.
//

import SwiftUI

struct KanaWritingRevealCardView: View {
    @ObservedObject var card: Card
    @ObservedObject var deck: Deck
    var textInput: String
    var body: some View {
        VStack {
            Divider()
            if textInput == card.currentFrontText {
                Text("You are correct!")
                    .font(.largeTitle)
                Text(card.currentFrontText)
                    .font(.largeTitle)
                    .background(Color.green)
            } else {
                Text("Incorrect")
                    .font(.largeTitle)
                CorrectedTextView(text: textInput, correctText: card.currentFrontText)
            }
            Text(card.backText)
                .font(.largeTitle)
            if let data = card.audioData {
                PlaySoundButton(audioData: data) {
                    Image(systemName: "speaker.wave.3.fill")
                        .imageScale(.large)
                }
            }
            Text(card.extra)
                .fixedSize(horizontal: false, vertical: true)
        }.onAppear {
            if let currentCard = deck.currentCard {
                currentCard.playSound()
            }
        }
    }
}

struct KanaWritingRevealCardView_Previews: PreviewProvider {
    static var previews: some View {
        KanaWritingRevealCardView(card: previewDeck.cards[0], deck: previewDeck, textInput: "asd")
    }
}
