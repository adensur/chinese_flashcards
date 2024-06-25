//
//  KanjiToTranslationRevealView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 14/11/2023.
//

import SwiftUI

struct KanaToTranslationRevealView: View {
    @ObservedObject var card: Card
    @ObservedObject var deck: Deck
    var body: some View {
        VStack {
            Divider()
            Text(card.currentBackText)
                .font(.largeTitle)
                .onAppear {
                    if let currentCard = deck.currentCard {
                        currentCard.playSound()
                    }
                }
            Text(card.kana)
                .font(.largeTitle)
                .foregroundStyle(.secondary)
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

struct KanaToTranslationRevealView_Previews: PreviewProvider {
    static var previews: some View {
        KanaToTranslationRevealView(card: previewDeck.cards[0], deck: previewDeck)
    }
}
