//
//  DeckSettingsView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 09/08/2023.
//

import SwiftUI

struct DeckSettingsView: View {
    @ObservedObject var deck: Deck
    var body: some View {
        Form {
            Section {
                Toggle("Shuffle cards?", isOn: $deck.shuffle)
            }
        }
    }
}

struct DeckSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        DeckSettingsView(deck: previewDeck)
    }
}
