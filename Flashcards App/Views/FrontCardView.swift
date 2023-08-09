//
//  FrontCardView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 11/07/2023.
//

import SwiftUI

struct FrontCardView: View {
    @Binding var reveal: Bool
    @ObservedObject var deck: Deck
    var body: some View {
        VStack {
            HStack{
                Spacer()
                // we have to do this extra check because of SwiftUI bug calling this even when it doesn't need to be displayed
                // https://stackoverflow.com/questions/76846330/swiftui-calls-onappear-for-views-that-should-not-exist
                if let currentCard = deck.currentCard {
                    Text(deck.currentCard!.frontText)
                    .onAppear {
                        print("FrontCardView on appear!", Date())
                        if let currentCard = deck.currentCard {
                            currentCard.playSound()
                        }
                    }
                }
                Spacer()
            }
            if let data = deck.currentCard?.audioData {
                PlaySoundButton(audioData: data) {
                    Image(systemName: "play")
                }
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            reveal = true
        }
    }
}

struct FrontCardView_Previews: PreviewProvider {
    static var previews: some View {
        FrontCardView(reveal: .constant(false), deck: previewDeck)
    }
}
