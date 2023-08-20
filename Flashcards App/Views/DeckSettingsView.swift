//
//  DeckSettingsView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 09/08/2023.
//

import SwiftUI

struct DeckSettingsView: View {
    @ObservedObject var deck: Deck
    @EnvironmentObject var decks: Decks
    @Environment(\.dismiss) var dismiss
    var deckDeleteCallback: () -> Void
    var body: some View {
        VStack {
            Form {
                Section {
                    Toggle("Shuffle cards?", isOn: $deck.shuffle)
                    Toggle("Disable all writing exercises", isOn: $deck.disableAllTextInputExercises)
                }
            }
            Spacer()
            Button("Delete") {
                // Perform save action here
                // hack to update the parent view
                decks.deleteDeck(deck: deck)
                dismiss()
                deckDeleteCallback()
            }
        }
    }
}

struct DeckSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        DeckSettingsView(deck: previewDeck) { }
    }
}
