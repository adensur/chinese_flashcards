//
//  AddCardView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 12/06/2023.
//

import SwiftUI

struct AddCardView: View {
    @ObservedObject var deck: Deck
    @Environment(\.presentationMode) var presentationMode
    @State private var frontText: String = ""
    @State private var backText: String = ""
    @State private var kana: String = ""
    @State private var wordType: EWordType = .unknown
    @State private var enableTextInputExercise: Bool = true
    @State private var audioData: Data? = nil
    @State var showSuggestionsSemafor = 0
    @State private var translations: [Detail] = []
    @FocusState private var isFocused: Bool
    
    var saveDisabled: Bool {
        return frontText.isEmpty || backText.isEmpty
    }
    
    var body: some View {
        Form {
            if deck.deckMetadata.frontLanguage == .Japanese {
                Section {
                    Picker(selection: $deck.lastUsedCardTemplate) {
                        ForEach(ECardTemplate.allValues(), id: \.self) {cardTemplate in
                            CardTemplateView(cardTemplate: cardTemplate)
                        }
                    } label: {
                        Text("card template")
                            .foregroundColor(.secondary)
                    }
                }
            }
            Section {
                HStack {
                    LanguageAwareTextField(LanguageAwareTexts.frontText(language: deck.deckMetadata.frontLanguage), text: $frontText, language: deck.deckMetadata.frontLanguage) {
                    }
                        .autocapitalization(.none)
                        .focused($isFocused)
                        .onChange(of: isFocused) {_ in
                            showSuggestionsSemafor = 0
                            print("focus changed! show suggestions is ", showSuggestionsSemafor)
                        }
                        .onChange(of: frontText) { _ in
                            print("onChange processing! ", Date())
                            showSuggestionsSemafor += 1
                        }
                    if let _ = deck.cards.first(where: {card in
                        card.frontText == frontText
                    }) {
                        Spacer()
                        Group {
                            Image(systemName: "exclamationmark.triangle")
                            Text("Word already added")
                        }.foregroundColor(.secondary)
                    }
                }
                if showSuggestionsSemafor > 0 {
                    if let vocab = vocabs.getVocab(languageFrom: deck.deckMetadata.frontLanguage.rawValue, languageTo: deck.deckMetadata.backLanguage.rawValue) {
                        SuggestView(inputText:$frontText,
                                    vocab: vocab
                        ) {vocabCard in
                            backText = vocabCard.backText
                            audioData = vocabCard.audioData
                            wordType = vocabCard.wordType
                            print("Setting editing to false", Date())
                            showSuggestionsSemafor = -1
                            print("Done setting editing to false", Date())
                        }
                    }
                }
                Picker(selection: $wordType) {
                    ForEach(EWordType.allValues(), id: \.self) {wordType in
                        WordTypeView(type: wordType)
                    }
                } label: {
                    Text("word type")
                        .foregroundColor(.secondary)
                }
            } header: {
                Text(LanguageAwareTexts.frontText(language: deck.deckMetadata.frontLanguage))
            }
            if deck.lastUsedCardTemplate == .threeWay {
                Section {
                    LanguageAwareTextField(LanguageAwareTexts.kana(language: deck.deckMetadata.frontLanguage), text: $kana, language: deck.deckMetadata.frontLanguage) { }
                        .autocapitalization(.none)
                } header: {
                    Text(LanguageAwareTexts.kana(language: deck.deckMetadata.frontLanguage))
                }
            }
            Section {
                TextFieldLookupView(text: $backText, wordType: $wordType, lookupText: frontText, translateFromLanguage: deck.deckMetadata.frontLanguage, translateToLanguage: deck.deckMetadata.backLanguage)
            } header: {
                Text("Back Text")
            }
            Section {
                SoundLookupView(lookupText: frontText, audioData: $audioData, languageToGetSoundFor: deck.deckMetadata.frontLanguage)
            } header: {
                Text("Sound")
            }
            Section {
                Toggle(isOn: $enableTextInputExercise) {
                    Text("Enable text input exercise")
                }
            } header: {
                Text("Exercise options")
            }
            //            .onTapGesture {
            //                print("OnTapGesture! Disabling focus. Was: ", isFocused)
            //                isFocused = false
            //            }
        }
        .onAppear() {
            if deck.deckMetadata.frontLanguage == .SimplifiedChinese {
                // always 3-way for chinese
                deck.lastUsedCardTemplate = .threeWay
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Adding Flashcard to \(deck.deckMetadata.name)")
        .navigationBarItems(
            leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            },
            trailing: Button("Save") {
                deck.addCard(frontText: frontText, backText: backText, kana: kana, audioData: audioData, enableTextInputExercise: enableTextInputExercise, wordType: wordType, cardTemplate: deck.lastUsedCardTemplate)
                presentationMode.wrappedValue.dismiss()
            }
                .disabled(saveDisabled)
        )
    }
}

struct AddCardView_Previews: PreviewProvider {
    static var previews: some View {
        AddCardView(deck: previewDeck)
    }
}
