//
//  AddCardView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 12/06/2023.
//

import SwiftUI


struct AddCardView: View {
    var deck: Deck
    @Environment(\.presentationMode) var presentationMode
    @State private var frontText: String = ""
    @State private var backText: String = ""
    @State private var enableTextInputExercise: Bool = true
    @State private var audioData: Data? = nil
    @State var showSuggestionsSemafor = 0
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Front Text", text: $frontText)
                        .focused($isFocused)
                        .onChange(of: isFocused) {_ in
                            showSuggestionsSemafor = 0
                            print("focus changed! show suggestions is ", showSuggestionsSemafor)
                        }
                        .onChange(of: frontText) { _ in
                            print("onChange processing! ", Date())
                            showSuggestionsSemafor += 1
                        }
                    if showSuggestionsSemafor > 0 {
                        SuggestView(inputText:$frontText) {vocabCard in
                            backText = vocabCard.backText
                            audioData = vocabCard.audioData
                            print("Setting editing to false", Date())
                            showSuggestionsSemafor = -1
                            print("Done setting editing to false", Date())
                        }
                    }
                } header: {
                    Text("FrontText")
                }
                Section {
                    TextField("Back Text", text: $backText)
                } header: {
                    Text("Back Text")
                }
                if let data = audioData {
                    PlaySoundButton(audioData: data) {
                        Image(systemName: "play")
                    }
                }
                Section {
                    Button("Get Sound!") {
                        Task {
                            print("Started getting sound!", Date())
                            audioData = await getSound(for: frontText, lang: "hi")
                            print("Got sound!", Date())
                            if audioData != nil {
                                print("Get sound success!")
                            } else {
                                print("Failed to get sound")
                            }
                        }
                    }.buttonStyle(BorderlessButtonStyle())
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
            }
            .onTapGesture {
                print("OnTapGesture! Disabling focus. Was: ", isFocused)
                isFocused = false
            }
        }.navigationTitle("Add Flashcard")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    deck.addCard(frontText: frontText, backText: backText, audioData: audioData, enableTextInputExercise: enableTextInputExercise)
                    presentationMode.wrappedValue.dismiss()
                }
            )
    }
}

struct AddCardView_Previews: PreviewProvider {
    static var previews: some View {
        AddCardView(deck: previewDeck)
    }
}
