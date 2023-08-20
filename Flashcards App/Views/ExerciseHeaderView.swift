//
//  SwiftUIView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 11/07/2023.
//

import SwiftUI

struct ExerciseHeaderView: View {
    @ObservedObject var deck: Deck
    var deckDeleteCallback: () -> Void
    var body: some View {
        GroupBox {
            HStack {
                Spacer()
                if let currentCard = deck.currentCard {
                    NavigationLink {
                        EditCardView(card: currentCard, deck: deck)
                    } label: {
                        Text("edit")
                    }
                }
                NavigationLink {
                    DeckSettingsView(deck: deck, deckDeleteCallback: deckDeleteCallback)
                } label: {
                    Text("deck settings")
                }
                NavigationLink {
                    AddCardView(deck: deck)
                } label: {
                    Text("add")
                }
                NavigationLink {
                    BrowseDeckView(deck: deck)
                } label: {
                    Text("browse")
                }
            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseHeaderView(deck: previewDeck) { }
    }
}
