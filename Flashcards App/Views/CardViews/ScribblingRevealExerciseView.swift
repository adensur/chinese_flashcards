//
//  ScribblingExerciseView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 14/10/2023.
//

import SwiftUI
import HanziWriter

struct ScribblingRevealExerciseView: View {
    @ObservedObject var card: Card
    var characters: [String] {
        return charactersFromString(card.currentFrontText)
    }
    
    var body: some View {
        VStack {
            Text(card.scribblePrompt)
                .font(.largeTitle)
            HStack {
                Spacer()
                ForEach(characters, id: \.self) {character in
                    if let characterData = characterHolder.data[character] {
                        CharacterView(character: characterHolder.data[character]!)
                    } else {
                        Text("Couldn't display \(character)")
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    ScribblingRevealExerciseView(card: previewDeck.cards[0])
}
