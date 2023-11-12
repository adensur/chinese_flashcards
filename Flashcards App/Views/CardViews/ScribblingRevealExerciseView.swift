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
    
    @State private var characterHolder: CharacterHolder? = nil
    
    var body: some View {
        VStack {
            Text(card.scribblePrompt)
                .font(.largeTitle)
            HStack {
                Spacer()
                ForEach(characters, id: \.self) {character in
                    if let holder = characterHolder {
                        if let characterData = holder.get(character) {
                            CharacterView(character: characterData)
                        } else {
                            Text("Couldn't display \(character)")
                        }
                    } else {
                        ProgressView()
                    }
                }
                Spacer()
            }
            Text(card.extra)
                .fixedSize(horizontal: false, vertical: true)
        }
        .onAppear {
            Task {
                characterHolder = await characterHolderSingleton.get()
            }
        }
    }
}

#Preview {
    ScribblingRevealExerciseView(card: previewDeck.cards[0])
}
