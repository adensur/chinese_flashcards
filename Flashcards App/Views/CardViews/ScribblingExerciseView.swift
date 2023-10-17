//
//  ScribblingExerciseView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 14/10/2023.
//

import SwiftUI
import HanziWriter

func loadAll() throws -> CharacterHolder {
    let result = CharacterHolder()
//    for source in ["chi", "hi", "kana", "kanji"] {
    for source in ["kana", "kanji"] {
        let url = if source == "chi" {
            Bundle.main.url(forResource: "chi", withExtension: "txt")!
        } else if source == "kana" {
            Bundle.main.url(forResource: "kana", withExtension: "json")!
        } else if source == "kanji" {
            Bundle.main.url(forResource: "kanji", withExtension: "json")!
        } else {
            Bundle.main.url(forResource: "hi", withExtension: "json")!
        }
        let chiHack = ["chi"].contains(source) ? true : false
        let holder = try! CharacterHolder.load(url: url, chiHack: chiHack)
        result.merge(from: holder)
    }
    return result
}

let characterHolder = try! loadAll()

func charactersFromString(_ str: String) -> [String] {
    var result: [String] = []
    for ch in str {
        result.append(String(ch))
    }
    return result
}

struct ScribblingExerciseView: View {
    @ObservedObject var card: Card
    // called when all characters are done
    var callback: () -> Void
    @State private var currentIdx = 0
    var characters: [String] {
        return charactersFromString(card.currentFrontText)
    }
    
    var body: some View {
        VStack {
            Text(card.scribblePrompt)
                .font(.largeTitle)
            if let characterData = getCharacter() {
                QuizCharacterView(dataModel: .init(character: characterData, showOutline: card.deck?.showOutline ?? true, canvasEnabled: true) {
                    next()
                })
            } else {
                Text("Couldn't display \(characters[currentIdx])")
                Button("skip") {
                    next()
                }
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
    
    func getCharacter() -> TCharacter? {
        return characterHolder.data[characters[currentIdx]]
    }
}

#Preview {
    ScribblingExerciseView(card: previewDeck.cards[0]) { }
}
