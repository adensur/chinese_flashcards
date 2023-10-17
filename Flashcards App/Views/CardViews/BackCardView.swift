//
//  BackSideView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 10/08/2023.
//

import SwiftUI

struct BackCardView: View {
    @ObservedObject var card: Card
    @ObservedObject var deck: Deck
    var body: some View {
        VStack {
            HStack {
                // make extra horizontal spacers to make sure the area is tappable
                Spacer()
                Text(card.currentBackText)
                    .font(.largeTitle)
                Spacer()
            }
            WordTypeView(type: card.type)
        }
    }
}

struct BackCardView_Previews: PreviewProvider {
    static var previews: some View {
        BackCardView(card: previewDeck.cards[0], deck: previewDeck)
    }
}
