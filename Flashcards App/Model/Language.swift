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
    case German = "de"
    case Italian = "it"
    case Russian = "ru"
    case Japanese = "ja"
    case Hindi = "hi"
    case Arabic = "ar"
    
    func longString() -> String {
        switch self {
        case .English:
            return "English"
        case .French:
            return "French"
        case .German:
            return "German"
        case .Italian:
            return "Italian"
        case .Russian:
            return "Russian"
        case .Japanese:
            return "Japanese"
        case .Hindi:
            return "Hindi"
        case .Arabic:
            return "Arabic"
        }
    }
    
    static func allValues() -> [ELanguage] {
        return [
            .English,
            .French,
            .German,
            .Italian,
            .Russian,
            .Japanese,
            .Hindi,
            .Arabic
        ]
    }
}
