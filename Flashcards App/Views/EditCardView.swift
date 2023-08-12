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
    @Environment(\.presentationMode) var presentationMode
    @State private var frontText: String = ""
    @State private var backText: String = ""
    @State private var enableTextInputExercise: Bool = false
    @State private var audioData: Data? = nil
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Front Text")) {
                        TextField("Front Text", text: $frontText)
                    }
                    
                    Section(header: Text("Back Text")) {
                        TextField("Back Text", text: $backText)
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
                    if let data = audioData {
                        PlaySoundButton(audioData: data) {
                            Image(systemName: "play")
                        }
                    }
                }.onAppear {
                    self.frontText = card.frontText
                    self.backText = card.backText
                    self.audioData = card.audioData
                }
                Spacer()
                Button("Delete") {
                    // Perform save action here
                    // hack to update the parent view
                    deck.deleteCard(id: card.id)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }.navigationTitle("Edit Flashcard")
        .navigationBarItems(
            leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            },
            trailing:
                Button("Save") {
                    // Perform save action here
                    card.frontText = frontText
                    card.backText = backText
                    card.enableTextInputExercise = enableTextInputExercise
                    card.audioData = audioData
                    presentationMode.wrappedValue.dismiss()
                }
        )
    }
}

struct EditCardView_Previews: PreviewProvider {
    static var previews: some View {
        EditCardView(card: previewDeck.cards[0], deck: previewDeck)
    }
}
