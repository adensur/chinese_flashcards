//
//  BackSideView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 10/08/2023.
//

import SwiftUI

struct BackCardView: View {
    @Binding var reveal: Bool
    @ObservedObject var card: Card
    @ObservedObject var deck: Deck
    var body: some View {
        VStack {
            VStack{
                Text(card.backText)
                    .font(.largeTitle)
                WordTypeView(type: card.type)
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            reveal = true
        }
    }
}

struct BackCardView_Previews: PreviewProvider {
    static var previews: some View {
        BackCardView(reveal: .constant(false), card: previewDeck.cards[0], deck: previewDeck)
    }
}
