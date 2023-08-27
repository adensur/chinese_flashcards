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
    @Environment(\.dismiss) var dismiss
    var body: some View {
        GroupBox {
            HStack {
                HStack {
                    Group {
                        Image(systemName: "chevron.left")
                        Button("back") {
                            dismiss()
                        }
                    }
                    .foregroundColor(.accentColor)
                }
                Spacer()
                if let currentCard = deck.currentCard {
                    NavigationLink {
                        EditCardView(card: currentCard, deck: deck)
                    } label: {
                        Text("edit")
                    }
                }
                Spacer()
                NavigationLink {
                    DeckSettingsView(deck: deck, deckDeleteCallback: deckDeleteCallback)
                } label: {
                    Text("settings")
                }
                Spacer()
                NavigationLink {
                    AddCardView(deck: deck)
                } label: {
                    Text("add")
                }
                Spacer()
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
