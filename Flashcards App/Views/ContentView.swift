//
//  ContentView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 08/06/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ExerciseView(deck: defaultDeck)
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
