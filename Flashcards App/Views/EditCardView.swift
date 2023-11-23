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
    @State private var kana: String = ""
    @State private var extra: String = ""
    @State private var wordType: EWordType = .unknown
    @State private var backText: String = ""
    @State private var enableTextInputExercise: Bool = false
    @State private var audioData: Data? = nil
    @State private var markAsLearnedAlertPresented: Bool = false
    @State private var resetProgressAlertPresented: Bool = false
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Front Text")) {
                    LanguageAwareTextField("Front Text", text: $frontText, language: deck.deckMetadata.frontLanguage) { }
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
                if case .japanese(_) = card.cardState {
                    Section {
                        LanguageAwareTextField("Kana", text: $kana, language: deck.deckMetadata.frontLanguage) { }
                            .autocapitalization(.none)
                    } header: {
                        Text("Kana")
                    }
                }
                Section(header: Text("Back Text")) {
                    TextFieldLookupView(text: $backText, wordType: $wordType, kana: $kana, extra: $extra, lookupText: frontText, translateFromLanguage: deck.deckMetadata.frontLanguage, translateToLanguage: deck.deckMetadata.backLanguage)
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
                Section {
                    Text("Next repetition: \(card.encodedNextRepetition())")
                    Button("Mark as learned") {
                        markAsLearnedAlertPresented = true
                    }
                    Button("Reset progress") {
                        resetProgressAlertPresented = true
                    }
                } header: {
                    Text("Stats")
                }
            }.onAppear {
                self.frontText = card.frontText
                self.wordType = card.type
                self.kana = card.kana
                self.backText = card.backText
                self.audioData = card.audioData
            }
            Spacer()
            Button {
                deck.deleteCard(id: card.id)
                dismiss()
            } label: {
                Text("Delete")
                    .padding()
                    .foregroundColor(.red)
            }
        }
        .alert("This will remove the card from exercise rotation, but you can still find it in your deck", isPresented: $markAsLearnedAlertPresented) {
            HStack {
                Button("OK") {
                    card.learningStage = .Learned
                    deck.save()
                }
                Button("Cancel") { }
            }
        }
        .alert("Are you sure?", isPresented: $resetProgressAlertPresented) {
            HStack {
                Button("OK") {
                    card.learningStage = .New
                    deck.save()
                }
                Button("Cancel") { }
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
                    card.kana = kana
                    card.extra = extra
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
