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
            VStack {
                Text(card.currentBackText)
                    .font(.largeTitle)
                WordTypeView(type: card.type)
            }
            LanguageAwareTextField(card.currentWritingPrompt, text: $textInput, language: deck.deckMetadata.frontLanguage, autocorrectionDisabled: true) {
                reveal = true
            }
            .disabled(reveal)
            .multilineTextAlignment(.center)
            .font(.largeTitle)
            .onAppear {
                print("BackWritingCardView onAppear for ex: ", card.frontText)
                self.focused.wrappedValue = true
            }
            .onChange(of: reveal) {
                print("BackWritingCardView onChange(of: reveal) for ex: ", card.frontText)
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

struct BackWritingCardView_Previews: PreviewProvider {
    static var previews: some View {
        BackWritingCardView(reveal: .constant(false), textInput: .constant("asd"), card: previewDeck.cards[0], deck: previewDeck, focused: FocusState<Bool>().projectedValue)
    }
}
