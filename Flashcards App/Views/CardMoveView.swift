//
//  CardMoveView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 06/09/2023.
//

import SwiftUI

struct CardMoveView: View {
    var decks: Decks
    var currentDeck: Deck
    var card: Card
    @Environment(\.dismiss) var dismiss
    var callback: () -> Void
    var body: some View {
        List {
            ForEach(decks.decks, id: \.savePath) {deck in
                if deck.savePath != currentDeck.deckMetadata.savePath {
                    HStack {
                        Text(deck.name)
                        Spacer()
                    }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            decks.moveCard(card: card, fromDeck: currentDeck, toDeck: Deck.load(deckMetadata: deck))
                            dismiss()
                            callback()
                        }
                }
            }
        }
    }
}

struct CardMoveView_Previews: PreviewProvider {
    static var previews: some View {
        CardMoveView(decks: Decks(), currentDeck: previewDeck, card: previewDeck.cards.first!) {}
    }
}
