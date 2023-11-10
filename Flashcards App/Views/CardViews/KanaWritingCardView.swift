//
//  BackWritingCardView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 10/08/2023.
//

import SwiftUI

struct KanaWritingCardView: View {
    @Binding var reveal: Bool
    @Binding var textInput: String
    @ObservedObject var card: Card
    @ObservedObject var deck: Deck
    var focused: FocusState<Bool>.Binding
    var body: some View {
        VStack {
            VStack {
                Text(card.frontText)
                    .font(.largeTitle)
                WordTypeView(type: card.type)
            }
            LanguageAwareTextField(LanguageAwareTexts.enterKana(language: deck.deckMetadata.frontLanguage), text: $textInput, language: deck.deckMetadata.frontLanguage) {
                reveal = true
            }
            .disabled(reveal)
            .multilineTextAlignment(.center)
            .font(.largeTitle)
            .onAppear {
                self.focused.wrappedValue = true
            }
            .focused(focused)
            .autocorrectionDisabled(true)
            .autocapitalization(.none)
            .padding(5)
            .border(Color.black, width: 1)
            .padding()
        }
    }
}

struct KanaWritingCardView_Previews: PreviewProvider {
    static var previews: some View {
        KanaWritingCardView(reveal: .constant(false), textInput: .constant("asd"), card: previewDeck.cards[0], deck: previewDeck, focused: FocusState<Bool>().projectedValue)
    }
}
