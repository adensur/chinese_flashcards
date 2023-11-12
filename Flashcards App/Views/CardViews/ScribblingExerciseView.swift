//
//  ScribblingExerciseView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 14/10/2023.
//

import SwiftUI
import HanziWriter

let characterHolderSingleton = CharacterHolderSingleton()

class CharacterHolderSingleton {
    private var characterHolder: CharacterHolder?
    private let semaphore = DispatchSemaphore(value: 1)

    func get() async -> CharacterHolder {
        if let characterHolder = characterHolder {
            return characterHolder
        }

        return await loadCharacterHolder()
    }

    private func loadCharacterHolder() async -> CharacterHolder {
        print("loadCharacterHolder")
        semaphore.wait()
        print("loadCharacterHolder after semaphor")
        // Check again if another thread has already initialized characterHolder
        if let existingHolder = characterHolder {
            semaphore.signal()
            return existingHolder
        }

        let holder = try! await loadAll()

        // Update characterHolder on the main queue
        self.characterHolder = holder
        self.semaphore.signal()

        return holder
    }
}

func loadAll() async throws -> CharacterHolder {
    print("CharacterHolder.loadAll()")
    let start = Date()
    let result = CharacterHolder()
//    for source in ["chi", "hi", "kana", "kanji"] {
    for source in ["kana", "kanji", "chi"] {
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
        let holder = try! await CharacterHolder.load(url: url, chiHack: chiHack)
        result.merge(from: holder)
    }
    print("CharacterHolder.loadAll() finished in ", start.timeIntervalSinceNow)
    return result
}

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
                characterHolder = await CharacterHolderSingleton().get()
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
        return holder.data[characters[currentIdx]]
    }
}

#Preview {
    ScribblingExerciseView(card: previewDeck.cards[0]) { }
}
