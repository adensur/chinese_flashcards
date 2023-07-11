//
//  RevealCardView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 11/07/2023.
//

import SwiftUI

struct RevealCardView: View {
    var card: Card
    var callback: (_: Difficulty) -> Void
    var body: some View {
        VStack {
            Divider()
            Text(card.backText)
            Spacer()
            HStack {
                Spacer()
                Button("\(card.getNextRepetitionTooltip(difficulty:.Again))\nAgain") {
                    callback(.Again)
                }
                Spacer()
                Button("\(card.getNextRepetitionTooltip(difficulty:.Hard))\nHard") {
                    callback(.Hard)
                }
                Spacer()
                Button("\(card.getNextRepetitionTooltip(difficulty:.Good))\nGood") {
                    callback(.Good)
                }
                Spacer()
                Button("\(card.getNextRepetitionTooltip(difficulty:.Easy))\nEasy") {
                    callback(.Easy)
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
