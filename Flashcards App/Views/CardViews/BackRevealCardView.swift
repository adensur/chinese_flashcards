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
    var body: some View {
        VStack {
            Divider()
            Text(card.currentFrontText)
                .font(.largeTitle)
                .onAppear {
                    if let currentCard = deck.currentCard {
                        currentCard.playSound()
                    }
                }
            if let data = card.audioData {
                PlaySoundButton(audioData: data) {
                    Image(systemName: "speaker.wave.3.fill")
                        .imageScale(.large)
                }
            }
            Text(card.extra)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct BackRevealCardView_Previews: PreviewProvider {
    static var previews: some View {
        BackRevealCardView(card: previewDeck.cards[0], deck: previewDeck)
    }
}
