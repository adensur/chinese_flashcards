//
//  EditCardView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 12/06/2023.
//

import SwiftUI

struct EditCardView: View {
    @ObservedObject var deck: Deck
    @Environment(\.presentationMode) var presentationMode
    @State private var frontText: String = ""
    @State private var backText: String = ""
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
                }.onAppear {
                    self.frontText = deck.currentCard!.frontText
                    self.backText = deck.currentCard!.backText
                }
                Spacer()
                Button("Delete") {
                    // Perform save action here
                    // hack to update the parent view
                    deck.deleteCurrentCard()
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
                    deck.currentCard!.frontText = frontText
                    deck.currentCard!.backText = backText
                    presentationMode.wrappedValue.dismiss()
                }
        )
    }
}

struct EditCardView_Previews: PreviewProvider {
    static var previews: some View {
        EditCardView(deck: previewDeck)
    }
}
