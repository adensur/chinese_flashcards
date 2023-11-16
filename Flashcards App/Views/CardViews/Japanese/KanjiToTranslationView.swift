//
//  KanjiToTranslationView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 14/11/2023.
//

import SwiftUI

struct KanjiToTranslationView: View {
    @ObservedObject var card: Card
    @ObservedObject var deck: Deck
    var body: some View {
        VStack {
            HStack {
                // make extra horizontal spacers to make sure the area is tappable
                Spacer()
                Text(card.currentBackText)
                    .font(.largeTitle)
                Spacer()
            }
            WordTypeView(type: card.type)
        }
    }
}

struct KanjiToTranslationView_Previews: PreviewProvider {
    static var previews: some View {
        KanjiToTranslationView(card: previewDeck.cards[0], deck: previewDeck)
    }
}
