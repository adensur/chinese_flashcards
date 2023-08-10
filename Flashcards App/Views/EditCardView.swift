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
                    self.frontText = card.frontText
                    self.backText = card.backText
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
