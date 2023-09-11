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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .offset(y: -100)
    }
}

private struct CustomButtonStyle: ButtonStyle {
    var pressedColor: Color
    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        let background = configuration.isPressed ? AnyView(pressedColor) : AnyView(EmptyView())
        configuration.label
            .background(background)
            .cornerRadius(8)
    }
}

struct SimpleDifficultyButtonsView: View {
    @ObservedObject var card: Card
    var callback: (_: Difficulty) -> Void
    @State private var okTapped = false
    var body: some View {
        HStack {
            Spacer()
            Button {
                callback(Difficulty.Hard)
            } label: {
                Text("nah")
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .offset(y: -100)
                    .contentShape(Rectangle())
            }
            .buttonStyle(CustomButtonStyle(pressedColor: .red))
            Spacer()
            Button {
                okTapped = false
                callback(Difficulty.Good)
            } label: {
                Text("ok")
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .offset(y: -100)
                    .contentShape(Rectangle())
            }
            .buttonStyle(CustomButtonStyle(pressedColor: .green))
            Spacer()
        }
    }
}

struct SimpleDifficultyButtonsViewPreviews: PreviewProvider {
    static var previews: some View {
        SimpleDifficultyButtonsView(card: previewDeck.cards[0]) {_ in}
    }
}
