//
//  DifficultyButtonsView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 05/09/2023.
//

import SwiftUI

struct AdvancedDifficultyButtonsView: View {
    @ObservedObject var card: Card
    var callback: (_: Difficulty) -> Void
    var body: some View {
        HStack {
            ForEach(Difficulty.allCases, id: \.self) {difficulty in
                Spacer()
                Button("\(card.getNextRepetitionTooltip(difficulty: difficulty))\n\(difficulty.rawValue)") {
                    callback(difficulty)
                }
                Spacer()
            }
        }
    }
}

struct SimpleDifficultyButtonsView: View {
    @ObservedObject var card: Card
    var callback: (_: Difficulty) -> Void
    var body: some View {
        HStack {
            Spacer()
            Button("nah") {
                callback(Difficulty.Hard)
            }
            Spacer()
            Button("ok") {
                callback(Difficulty.Good)
            }
            Spacer()
        }
    }
}

struct SimpleDifficultyButtonsViewPreviews: PreviewProvider {
    static var previews: some View {
        SimpleDifficultyButtonsView(card: previewDeck.cards[0]) {_ in}
    }
}
