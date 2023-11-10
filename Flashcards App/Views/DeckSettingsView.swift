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
    @State private var deleteAlertPresented = false
    var body: some View {
        VStack {
            Form {
                Section {
                    Picker("Language to learn", selection: $deck.deckMetadata.frontLanguage) {
                        ForEach(ELanguage.allValues(), id: \.self) {language in
                            Text("\(language.longString())")
                        }
                    }
                } header: {
                    Text("Learning language")
                }
                Section {
                    Picker("Back of the card language", selection: $deck.deckMetadata.backLanguage) {
                        ForEach(ELanguage.allValues(), id: \.self) {language in
                            Text("\(language.longString())")
                        }
                    }
                } header: {
                    Text("Language You Speak")
                }
                Section {
                    Toggle("Disable sound", isOn: $deck.disableSound)
                    Toggle("Shuffle cards?", isOn: $deck.shuffle)
                    Toggle("Disable all writing exercises", isOn: $deck.disableAllTextInputExercises)
                    Toggle("Enable advanced difficulty options", isOn: $deck.showAdvancedDifficultyButtons)
                }
                if deck.deckMetadata.frontLanguage.isHieroglyphLanguage() {
                    Section {
                        Toggle("Show outline", isOn: $deck.showOutline)
                    } header: {
                        Text("Scribbling exercise options")
                    }
                }
            }
            Spacer()
            Button("Delete Deck", role: .destructive) {
                if deck.cards.isEmpty {
                    deleteDeck()
                } else {
                    deleteAlertPresented = true
                }
            }
        }
        .alert("You are about to delete deck with \(deck.cards.count) cards.", isPresented: $deleteAlertPresented) {
            HStack {
                Button("OK") {
                    deleteDeck()
                }
                Button("Cancel") { }
            }
        }
    }
        
    func deleteDeck() {
        decks.deleteDeck(deck: deck)
        dismiss()
        deckDeleteCallback()
    }
}

struct DeckSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        DeckSettingsView(deck: previewDeck) { }
    }
}
