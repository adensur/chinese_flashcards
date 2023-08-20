//
//  Language.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 20/08/2023.
//

import Foundation

enum ELanguage: String {
    case English = "en"
    case French = "fr"
    case Hindi = "hi"
    case Italian = "it"
    static func allValues() -> [ELanguage] {
        return [
            .English,
            .French,
            .Italian,
            .Hindi
        ]
    }
}
