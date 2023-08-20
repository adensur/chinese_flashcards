//
//  DecksView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 20/08/2023.
//

import SwiftUI

struct DecksView: View {
    @ObservedObject var decks: Decks
    var body: some View {
        List {
            ForEach(decks.decks, id: \.savePath) {deckMetadata in
                NavigationLink("\(deckMetadata.name)") {
                    ExerciseView(deck: load(deckMetadata: deckMetadata))
                }
            }
        }
    }
}

struct DecksView_Previews: PreviewProvider {
    static var previews: some View {
        DecksView(decks: Decks.load())
    }
}
