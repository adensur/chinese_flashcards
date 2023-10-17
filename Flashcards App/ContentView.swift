//
//  ContentView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 08/06/2023.
//

import SwiftUI
import HanziWriter

struct ContentView: View {
    // tmp
//    @ObservedObject var dataModel = QuizDataModel(character: characterHolder.data["田"]!) { }
    
    @StateObject var decks: Decks = Decks.load()
    var body: some View {
//        QuizCharacterView(dataModel: dataModel)
        NavigationStack {
            DecksView()
                .padding()
                .preferredColorScheme(.dark)
        }
        .environmentObject(decks)
        .onAppear {
            vocabUpdater.updateVocabs(decks: decks.decks)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
