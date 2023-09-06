//
//  RevealCardView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 11/07/2023.
//

import SwiftUI

struct RevealCardView: View {
    @ObservedObject var card: Card
    @ObservedObject var deck: Deck
    var callback: (_: Difficulty) -> Void
    var body: some View {
        VStack {
            Divider()
            VStack {
                Text(card.backText)
                    .font(.largeTitle)
                WordTypeView(type: card.type)
            }
            Spacer()
            if deck.showAdvancedDifficultyButtons {
                AdvancedDifficultyButtonsView(card: card, callback: callback)
            } else {
                SimpleDifficultyButtonsView(card: card, callback: callback)
            }
        }
    }
}

struct RevealCardView_Previews: PreviewProvider {
    static var previews: some View {
        RevealCardView(card: previewDeck.cards[0], deck: previewDeck) {_ in
        }
    }
}
