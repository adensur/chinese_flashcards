//
//  ContentView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 08/06/2023.
//

import SwiftUI

struct ContentView: View {
    var vocab = defaultVocab
    @StateObject var decks: Decks = Decks.load()
    var body: some View {
        NavigationStack {
            DecksView()
                .padding()
        }
        .environmentObject(Decks.load())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
