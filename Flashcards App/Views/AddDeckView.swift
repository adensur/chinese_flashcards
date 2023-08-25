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
    @State private var alertPresented = false
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
                        Text("\(language.rawValue)")
                    }
                }
            } header: {
                Text("Learning language")
            }
            Section {
                Picker("Back of the card language", selection: $backLanguage) {
                    ForEach(ELanguage.allValues(), id: \.self) {language in
                        Text("\(language.rawValue)")
                    }
                }
            } header: {
                Text("Language You Speak")
            }
        }
        .navigationTitle("Add deck")
        .navigationBarItems(
            leading: Button("Cancel") {
                dismiss()
            },
            trailing: Button("Save") {
                if valuesAreValid() {
                    decks.addDeck(.init(name: name, frontLanguage: frontLanguage, backLanguage: backLanguage))
                    dismiss()
                } else {
                    alertPresented = true
                }
            }
        )
        .alert(
            Text("Deck name cannot be empty!"),
            isPresented: $alertPresented) {
                Button("OK") { }
            }
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
