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
    var body: some View {
        VStack {
            Divider()
            VStack {
                Text(card.currentBackText)
                    .font(.largeTitle)
                WordTypeView(type: card.type)
            }
            Text(card.extra)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct RevealCardView_Previews: PreviewProvider {
    static var previews: some View {
        RevealCardView(card: previewDeck.cards[0], deck: previewDeck)
    }
}
