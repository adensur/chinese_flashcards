//
//  SwiftUIView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 11/07/2023.
//

import SwiftUI

struct ExerciseHeaderView: View {
    let currentCard: Card?
    var body: some View {
        GroupBox {
            HStack {
                Spacer()
                if let currentCard = currentCard {
                    NavigationLink {
                        EditCardView(card: currentCard)
                    } label: {
                        Text("edit")
                    }
                }
                NavigationLink {
                    AddCardView()
                } label: {
                    Text("add")
                }
            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseHeaderView(currentCard: previewDeck.cards[0])
    }
}
