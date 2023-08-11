//
//  BackWritingCardView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 10/08/2023.
//

import SwiftUI

struct BackWritingCardView: View {
    @Binding var reveal: Bool
    @Binding var textInput: String
    @ObservedObject var card: Card
    @ObservedObject var deck: Deck
    var focused: FocusState<Bool>.Binding
    var body: some View {
        VStack {
            HStack{
                Spacer()
                Text(card.backText)
                Spacer()
            }
            TextField("Enter translation", text: $textInput)
                .onAppear {
                    self.focused.wrappedValue = true
                }
                .focused(focused)
                .autocorrectionDisabled(true)
                .padding(5)
                .border(Color.black, width: 1)
                .onSubmit {
                    reveal = true
                }
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    BackWritingCardView(reveal: .constant(false), textInput: .constant("asd"), card: previewDeck.cards[0], deck: previewDeck, focused: FocusState<Bool>().projectedValue)
}
