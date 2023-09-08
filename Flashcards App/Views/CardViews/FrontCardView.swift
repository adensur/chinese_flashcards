//
//  FrontCardView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 11/07/2023.
//

import SwiftUI

struct FrontCardView: View {
    @ObservedObject var card: Card
    @ObservedObject var deck: Deck
    var body: some View {
        VStack {
            HStack {
                Spacer()
                // we have to do this extra check because of SwiftUI bug calling this even when it doesn't need to be displayed
                // https://stackoverflow.com/questions/76846330/swiftui-calls-onappear-for-views-that-should-not-exist
                Text(card.frontText)
                    .font(.largeTitle)
                    .onAppear {
                        if let currentCard = deck.currentCard {
                            print("Card word type: ", card.type.toString())
                            if currentCard.isFrontSideUp {
                                currentCard.playSound()
                            }
                        }
                    }
                Spacer()
            }
            if let data = card.audioData {
                PlaySoundButton(audioData: data) {
                    Image(systemName: "play")
                        .imageScale(.large)
                }
            }
        }
    }
}

struct FrontCardView_Previews: PreviewProvider {
    static var previews: some View {
        FrontCardView(card: previewDeck.cards[0], deck: previewDeck)
    }
}
