//
//  ScribbleCharacterHolder.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 12/11/2023.
//

import Foundation
import HanziWriter

let characterHolderSingleton = CharacterHolderSingleton()

class CharacterHolderSingleton {
    private var data: [ELanguage: CharacterHolder] = [:]
    private let semaphore = DispatchSemaphore(value: 1)

    func get(language: ELanguage) async -> CharacterHolder {
        let start = Date()
        if let characterHolder = data[language] {
            return characterHolder
        }
        return await loadCharacterHolder(language: language)
    }

    private func loadCharacterHolder(language: ELanguage) async -> CharacterHolder {
        semaphore.wait()
        // Check again if another thread has already initialized characterHolder
        if let existingHolder = data[language] {
            semaphore.signal()
            return existingHolder
        }

        let holder = try! await load(language: language)

        // Update characterHolder on the main queue
        self.data[language] = holder
        self.semaphore.signal()

        return holder
    }
}

func load(language: ELanguage) async throws -> CharacterHolder {
    print("CharacterHolder.loadAll()")
    let start = Date()
    let chiHack = language == .SimplifiedChinese
    let result = CharacterHolder(chiHack: chiHack)
    var sources = Array<String>()
    if language == .SimplifiedChinese {
        sources = ["chi"]
    } else if language == .Japanese {
        sources = ["kanji", "kana"]
    } else {
        return result
    }
    for source in sources {
        let url = if source == "chi" {
            Bundle.main.url(forResource: "chi", withExtension: "txt")!
        } else if source == "kana" {
            Bundle.main.url(forResource: "kana", withExtension: "json")!
        } else if source == "kanji" {
            Bundle.main.url(forResource: "kanji", withExtension: "json")!
        } else {
            Bundle.main.url(forResource: "hi", withExtension: "json")!
        }
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
