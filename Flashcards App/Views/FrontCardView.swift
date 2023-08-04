//
//  FrontCardView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 11/07/2023.
//

import SwiftUI

struct FrontCardView: View {
    @Binding var reveal: Bool
    @ObservedObject var card: Card
    var body: some View {
        VStack {
            HStack{
                Spacer()
                Text(card.frontText)
                    .onChange(of: card) {card in
                        print("Card on appear!", Date())
                        card.playSound()
                    }
                    .onAppear {
                        card.playSound()
                    }
                    
                Spacer()
            }
            if let data = card.audioData {
                PlaySoundButton(audioData: data) {
                    Image(systemName: "play")
                }
            }
            Spacer()
        }
        .contentShape(Rectangle())
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
