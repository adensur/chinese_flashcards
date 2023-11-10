//
//  LanguageAwareTexts.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 10/11/2023.
//

import Foundation

class LanguageAwareTexts {
    static func kana(language: ELanguage) -> String {
        if language == .SimplifiedChinese {
            return "Pinyin"
        } else {
            return "Kana"
        }
    }
    
    static func frontText(language: ELanguage) -> String {
        if language == .SimplifiedChinese {
            return "Hanzi"
        } else if language == .Japanese {
            return "Kanji"
        }
        return "Front Text"
    }
    
    static func enterKana(language: ELanguage) -> String {
        if language == .SimplifiedChinese {
            return "Enter pinyin"
        } else {
            return "Enter kana"
        }
    }
}
