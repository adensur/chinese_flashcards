//
//  BrowseDeckView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 15/07/2023.
//

import SwiftUI

struct BrowseDeckView: View {
    @ObservedObject var deck: Deck
    var body: some View {
        List {
            ForEach(deck.cards) {card in
                NavigationLink {
                    EditCardView(card: card, deck: deck)
                } label: {
                    HStack{
                        Text(card.frontText)
                        Text(card.backText)
                        Spacer()
                        Text("\(card.formattedCreationDate())")
                    }
                }
            }
        }
    }
}

struct BrowseDeckView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseDeckView(deck: previewDeck)
    }
}
