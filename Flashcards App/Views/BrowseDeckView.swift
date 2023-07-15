//
//  BrowseDeckView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 15/07/2023.
//

import SwiftUI

struct BrowseDeckView: View {
    var deck: Deck
    var body: some View {
        List {
            ForEach(deck.cards) {card in
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

struct BrowseDeckView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseDeckView(deck: previewDeck)
    }
}
