//
//  Exercise.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 08/06/2023.
//

import Foundation

// simple exercise. Front and back text, no value checking - just turning the card over
class Card {
    var FrontText: String
    var BackText: String
    init(FrontText: String, BackText: String) {
        self.FrontText = FrontText
        self.BackText = BackText
    }
    
    func consumeAnswer(difficulty: Difficulty) {
        // todo!
    }
    
    func isReady() -> Bool {
        return true
    }
}
