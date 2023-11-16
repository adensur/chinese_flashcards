//
//  ScribblingExerciseView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 14/10/2023.
//

import SwiftUI
import HanziWriter

struct ScribblingExerciseView: View {
    let language: ELanguage
    @ObservedObject var card: Card
    // called when all characters are done
    var callback: () -> Void
    @State private var currentIdx = 0
    var characters: [String] {
        return charactersFromString(card.currentFrontText)
    }
    @State private var characterHolder: CharacterHolder?
    
    var body: some View {
        VStack {
            Text(card.scribblePrompt)
                .font(.largeTitle)
            if let holder = characterHolder {
                if let characterData = getCharacter(holder) {
                    QuizCharacterView(dataModel: .init(character: characterData, showOutline: card.deck?.showOutline ?? true, canvasEnabled: true) {
                        next()
                    })
                } else {
                    Text("Couldn't display \(characters[currentIdx])")
                    Button("skip") {
                        next()
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onAppear() {
            Task {
                print("loading holder")
                let start = Date()
                characterHolder = await characterHolderSingleton.get(language: language)
                print("finished loading holder in ", Date().timeIntervalSince(start))
            }
        }
    }
    
    func next() {
        if currentIdx == characters.count - 1 {
            // call external callback - this should move to the next exercise
            callback()
            return
        }
        currentIdx += 1
    }
    
    func getCharacter(_ holder: CharacterHolder) -> TCharacter? {
        return holder.get(characters[currentIdx])
    }
}

#Preview {
    ScribblingExerciseView(language: .SimplifiedChinese, card: previewDeck.cards[0]) { }
}
