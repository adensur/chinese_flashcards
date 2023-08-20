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
    case Italian = "it"
    case Russian = "ru"
    case Hindi = "hi"
    
    static func allValues() -> [ELanguage] {
        return [
            .English,
            .French,
            .Italian,
            .Russian,
            .Hindi
        ]
    }
}
