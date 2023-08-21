//
//  DecksView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 20/08/2023.
//

import SwiftUI

struct DecksView: View {
    @EnvironmentObject var decks: Decks
    var body: some View {
        List {
            ForEach(decks.decks, id: \.savePath) {deckMetadata in
                NavigationLink("\(deckMetadata.name)") {
                    LazyView {
                        ExerciseView(deck: Deck.load(deckMetadata: deckMetadata))
                    }
                }
            }
            Section {
                NavigationLink {
                    AddDeckView(decks: decks)
                } label: {
                    Text("Add Deck")
                    .foregroundColor(.accentColor)
                }
            }
        }
    }
}

struct DecksView_Previews: PreviewProvider {
    static var previews: some View {
        DecksView()
    }
}
