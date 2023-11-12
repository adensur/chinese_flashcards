//
//  ContentView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 08/06/2023.
//

import SwiftUI
import HanziWriter

let char = "ー"

struct ContentView: View {
    @StateObject var decks: Decks = Decks.load()
    var body: some View {
        NavigationStack {
            DecksView()
                .padding()
                .preferredColorScheme(.dark)
        }
        .environmentObject(decks)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
