//
//  CardCountsView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 23/08/2023.
//

import SwiftUI

struct CardCounts {
    var new: Int
    var repeating: Int
    var learning: Int
}

struct CardCountsView: View {
    var cardCounts: CardCounts
    var body: some View {
        HStack {
            Text("\(cardCounts.new)")
                .foregroundColor(.indigo)
            Text("+")
            Text("\(cardCounts.learning)")
                .foregroundColor(.orange)
            Text("+")
            Text("\(cardCounts.repeating)")
                .foregroundColor(.teal)
        }
        .padding()
    }
}

struct CardCountsView_Previews: PreviewProvider {
    static var previews: some View {
        CardCountsView(cardCounts: CardCounts(new: 3, repeating: 7, learning: 2))
    }
}
