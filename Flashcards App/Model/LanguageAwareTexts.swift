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
    
    static func frontPlaceholder(language: ELanguage, template: ECardTemplate) -> String {
        if language == .SimplifiedChinese {
            return "Hanzi"
        } else if language == .Japanese {
            switch template {
            case .twoWay:
                return "Japanese"
            case .threeWay:
                return "Japanese"
            case .twoWayKana:
                return "Japanese"
            }
        }
        return "Front Text"
    }
    
    static func frontText(language: ELanguage, template: ECardTemplate) -> String {
        if language == .SimplifiedChinese {
            return "Hanzi"
        } else if language == .Japanese {
            switch template {
            case .twoWay:
                return "Japanese word"
            case .threeWay:
                return "Kanji"
            case .twoWayKana:
                return "Kana"
            }
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
