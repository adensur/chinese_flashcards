//
//  FrontCardView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 11/07/2023.
//

import SwiftUI

struct FrontCardView: View {
    @Binding var reveal: Bool
    @StateObject var card: Card
    var body: some View {
        VStack {
            HStack{
                Spacer()
                Text(card.frontText)
                Spacer()
            }
            Spacer()
        } .contentShape(Rectangle())
        .onTapGesture {
            reveal = true
        }
    }
}

struct FrontCardView_Previews: PreviewProvider {
    static var previews: some View {
        FrontCardView(reveal: .constant(false), card: previewDeck.cards[0])
    }
}
