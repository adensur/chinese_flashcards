//
//  DecksView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 20/08/2023.
//

import SwiftUI

struct DecksView: View {
    @EnvironmentObject var decks: Decks
    @State private var deleteAlertPresented = false
    @State private var decksToDelete = IndexSet([])
    var body: some View {
        List {
            ForEach(decks.decks, id: \.savePath) {deckMetadata in
                NavigationLink("\(deckMetadata.name)") {
                    LazyView {
                        ExerciseView(deck: Deck.load(deckMetadata: deckMetadata))
                    }
                }
            }.onDelete {indexSet in
                deleteAlertPresented = true
                decksToDelete = indexSet
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
        .alert("Are you sure you want to delete the deck?", isPresented: $deleteAlertPresented) {
            HStack {
                Button("Cancel", role: .cancel) {}
                Button("OK", role: .destructive) {
                    decks.deleteDecks(atOffsets: decksToDelete)
                }
            }
        }
        .onAppear {
            
            Task {
                // async preload all saved decks from disk
                for deck in decks.decks {
                    let _ = Deck.load(deckMetadata: deck)
                }
            }
             Task {
//            Task.detached(priority: .medium) {
                 let _ = await characterHolderSingleton.get().data["ー"]
            }
        }
    }
}

struct DecksView_Previews: PreviewProvider {
    static var previews: some View {
        DecksView()
    }
}
