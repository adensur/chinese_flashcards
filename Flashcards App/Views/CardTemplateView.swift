//
//  CardTemplateView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 16/10/2023.
//

import SwiftUI

enum ECardTemplate: Codable {
    case twoWay
    case threeWay
    case twoWayKana
    static func allValues() -> [ECardTemplate] {
        return [
            .twoWay,
            .threeWay,
            .twoWayKana,
        ]
    }
}

struct CardTemplateView: View {
    var cardTemplate: ECardTemplate
    var body: some View {
        switch cardTemplate {
        case .twoWay:
            Text("2-way: front to back text")
        case .threeWay:
            Text("3-way: kanji - kana - translation")
        case .twoWayKana:
            Text("2-way: kana scribbling - romanization")
        }
    }
}

#Preview {
    CardTemplateView(cardTemplate: .twoWay)
}
