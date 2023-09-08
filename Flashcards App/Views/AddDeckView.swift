//
//  AddDeckView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 20/08/2023.
//

import SwiftUI

struct AddDeckView: View {
    @ObservedObject var decks: Decks
    @State private var name: String = ""
    @State private var frontLanguage: ELanguage = .French
    @State private var backLanguage: ELanguage = .English
    @Environment(\.dismiss) var dismiss
    var body: some View {
        Form {
            Section {
                TextField("Enter deck name", text: $name)
            } header: {
                Text("Deck Name")
            }
            Section {
                Picker("Language to learn", selection: $frontLanguage) {
                    ForEach(ELanguage.allValues(), id: \.self) {language in
                        Text("\(language.longString())")
                    }
                }
            } header: {
                Text("Learning language")
            }
            Section {
                Picker("Back of the card language", selection: $backLanguage) {
                    ForEach(ELanguage.allValues(), id: \.self) {language in
                        Text("\(language.longString())")
                    }
                }
            } header: {
                Text("Language You Speak")
            }
        }
        .navigationTitle("Add deck")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button("Cancel") {
                dismiss()
            },
            trailing: Button("Save") {
                decks.addDeck(.init(name: name, frontLanguage: frontLanguage, backLanguage: backLanguage))
                dismiss()
            }.disabled(!valuesAreValid())
        )
    }
    
    func valuesAreValid() -> Bool {
        if name.isEmpty {
            return false
        }
        return true
    }
}

struct AddDeckView_Previews: PreviewProvider {
    static var previews: some View {
        AddDeckView(decks: Decks.previewLoad())
    }
}
