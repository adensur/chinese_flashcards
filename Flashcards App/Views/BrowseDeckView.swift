//
//  BrowseDeckView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 15/07/2023.
//

import SwiftUI

struct BrowseDeckView: View {
    @ObservedObject var deck: Deck
    @State private var filterText: String = ""
    @State private var filterBy = "frontText"
    var filteredCards: [Card] {
        deck.cards.filter {card in
            if filterText.isEmpty {
                return true
            }
            if filterBy == "frontText" {
                return card.frontText.contains(filterText.lowercased())
            } else {
                return card.backText.contains(filterText.lowercased())
            }
        }
    }
    var body: some View {
        List {
            Section {
                Picker("Filter by", selection: $filterBy) {
                    ForEach(["frontText", "backText"], id: \.self) {text in
                        Text("\(text)")
                    }
                }
                LanguageAwareTextField("Filter", text: $filterText, language: deck.deckMetadata.frontLanguage) { }
            } header: {
                Text("Filter")
            }
            ForEach(filteredCards) {card in
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
