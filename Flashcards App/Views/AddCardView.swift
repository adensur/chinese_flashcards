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
            MyForm {
                MySection {
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
                    Group {
                        if showSuggestionsSemafor > 0 {
                            SuggestView(inputText:$frontText) {vocabCard in
                                backText = vocabCard.backText
                                audioData = vocabCard.audioData
                                print("Setting editing to false", Date())
                                showSuggestionsSemafor = -1
                                print("Done setting editing to false", Date())
                            }
                        }
                    }
                } header: {
                    Text("FrontText")
                }
                MySection {
                    TextField("Back Text", text: $backText)
                } header: {
                    Text("Back Text")
                }
                Group {
                    if let data = audioData {
                        PlaySoundButton(audioData: data) {
                            Image(systemName: "play")
                        }
                    }
                }
                MySection {
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
