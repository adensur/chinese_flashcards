//
//  WordTranslationLookupView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 18/08/2023.
//

import SwiftUI

struct WordTranslationLookupView: View {
    var word: String
    var translations: [Detail]
    var callback: (Detail) -> Void
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        if !translations.isEmpty {
            List {
                Section {
                    ForEach(translations, id: \.self.word) {detail in
                        HStack {
                            Text("\(detail.word)")
                            WordTypeView(type: detail.type)
                            Spacer()
                            FreqView(freq: detail.freq)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            print("WordTranslationLookupView onTapGesture!")
                            callback(detail)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                } header: {
                    HStack {
                        Text("translation")
                        Spacer()
                        Text("frequency")
                    }
                }
            }
        } else {
            VStack {
                Text("Sorry, no entries found for \(word)")
                Spacer()
            }
        }
    }
}

struct WordTranslationLookupView_Previews: PreviewProvider {
    static var previews: some View {
        WordTranslationLookupView(word: "SomeWord", translations: [Detail](arrayLiteral:
        .init(word: "word1", freq: 1, type: .noun),
        .init(word: "word2", freq: 2, type: .verb),
        .init(word: "word3", freq: 3, type: .adjective)
        )) {_ in}
    }
}
