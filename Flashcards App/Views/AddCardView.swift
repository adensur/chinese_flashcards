//
//  AddCardView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 12/06/2023.
//

import SwiftUI

struct AddCardView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var frontText: String = ""
    @State private var backText: String = ""
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Front Text")) {
                    TextField("Front Text", text: $frontText)
                }
                
                Section(header: Text("Back Text")) {
                    TextField("Back Text", text: $backText)
                }
            }
        }.navigationTitle("Add Flashcard")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    // Perform save action here
                    defaultDeck.cards.append(Card(frontText: frontText, backText: backText))
                    presentationMode.wrappedValue.dismiss()
                }
            )
    }
}

struct AddCardView_Previews: PreviewProvider {
    static var previews: some View {
        AddCardView()
    }
}
