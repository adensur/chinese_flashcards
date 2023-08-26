//
//  RevealCardView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 11/07/2023.
//

import SwiftUI

struct RevealCardView: View {
    @ObservedObject var card: Card
    var callback: (_: Difficulty) -> Void
    var body: some View {
        VStack {
            Divider()
            HStack {
                Text(card.backText)
                WordTypeView(type: card.type)
            }
            Spacer()
            HStack {
                ForEach(Difficulty.allCases, id: \.self) {difficulty in
                    Spacer()
                    Button("\(card.getNextRepetitionTooltip(difficulty: difficulty))\n\(difficulty.rawValue)") {
                        callback(difficulty)
                    }
                }
                Spacer()
            }
        }
    }
}

struct RevealCardView_Previews: PreviewProvider {
    static var previews: some View {
        RevealCardView(card: previewDeck.cards[0]) {_ in
        }
    }
}
