//
//  Language.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 20/08/2023.
//

import Foundation

enum ELanguage: String {
    // raw values correspond to google translate API two-letter language codes
    // Warning! This is not the same as BCP 47 codes. For example, here "iw" stands for "Hebrew" whish is "he" in BCP47
    case English = "en"
    case French = "fr"
    case German = "de"
    case Italian = "it"
    case Russian = "ru"
    case Japanese = "ja"
    case Hindi = "hi"
    case Arabic = "ar"
    case Hebrew = "iw"
    
    // https://appmakers.dev/bcp-47-language-codes-list/
    var bcp47Code: String {
        switch self {
        case .Hebrew:
            return "he"
        default:
            return self.rawValue
        }
    }
    
    
    var isRtl: Bool {
        switch self {
        case .Hebrew:
            return true
        case .Arabic:
            return true
        default:
            return false
        }
    }
        
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
            case .Hebrew:
                return "Hebrew"
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
                .Arabic,
                .Hebrew
            ]
        }
    }
