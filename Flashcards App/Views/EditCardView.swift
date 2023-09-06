//
//  EditCardView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 12/06/2023.
//

import SwiftUI

struct EditCardView: View {
    @ObservedObject var card: Card
    @ObservedObject var deck: Deck
    @Environment(\.dismiss) var dismiss
    @State private var frontText: String = ""
    @State private var wordType: EWordType = .unknown
    @State private var backText: String = ""
    @State private var enableTextInputExercise: Bool = false
    @State private var audioData: Data? = nil
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Front Text")) {
                    TextField("Front Text", text: $frontText)
                        .autocapitalization(.none)
                    Picker(selection: $wordType) {
                        ForEach(EWordType.allValues(), id: \.self) {wordType in
                            WordTypeView(type: wordType)
                        }
                    } label: {
                        Text("word type")
                            .foregroundColor(.secondary)
                    }
                }
                Section(header: Text("Back Text")) {
                    TextFieldLookupView(text: $backText, wordType: $wordType, lookupText: frontText, translateFromLanguage: deck.deckMetadata.frontLanguage, translateToLanguage: deck.deckMetadata.backLanguage)
                }
                Section {
                    SoundLookupView(lookupText: frontText, audioData: $audioData, languageToGetSoundFor: deck.deckMetadata.frontLanguage)
                } header: {
                    Text("Sound")
                }
                Section {
                    Toggle(isOn: $enableTextInputExercise) {
                        Text("Enable text input exercise")
                    }.onAppear {
                        enableTextInputExercise = card.enableTextInputExercise
                    }
                } header: {
                    Text("Exercise Options")
                }
                NavigationLink("Move") {
                    CardMoveView(decks: deck.deckMetadata.decks!, currentDeck: deck, card: card) {
                        dismiss()
                    }
                }
            }.onAppear {
                self.frontText = card.frontText
                self.wordType = card.type
                self.backText = card.backText
                self.audioData = card.audioData
            }
            Spacer()
            Button {
                deck.deleteCard(id: card.id)
                dismiss()
            } label: {
                Text("Delete")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Edit Flashcard")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button("Cancel") {
                dismiss()
            },
            trailing:
                Button("Save") {
                    // Perform save action here
                    card.frontText = frontText
                    card.type = wordType
                    card.backText = backText
                    card.enableTextInputExercise = enableTextInputExercise
                    card.audioData = audioData
                    dismiss()
                }
        )
    }
}

struct EditCardView_Previews: PreviewProvider {
    static var previews: some View {
        EditCardView(card: previewDeck.cards[0], deck: previewDeck)
    }
}
