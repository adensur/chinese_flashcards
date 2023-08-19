//
//  WordTranslationLookupView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 18/08/2023.
//

import SwiftUI

struct WordTranslationLookupView: View {
    var word: String
    @State private var translations: [Detail] = []
    @State private var doneLoading = false
    var callback: (Detail) -> Void
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        Group {
            if !doneLoading {
                Text("Loading...")
                Spacer()
            } else if translations.isEmpty {
                Text("No entries found for \(word)")
                Spacer()
            } else {
                List {
                    ForEach(translations, id: \.self.word) {detail in
                        HStack {
                            Text("\(detail.word)")
                            Text("\(detail.type.toString())")
                            Text("\(detail.freq)")
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            print("WordTranslationLookupView onTapGesture!")
                            callback(detail)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }.onAppear {
            Task {
                translations = await getTranslation(for: word, lang: "hi")
                doneLoading = true
            }
        }
    }
}

struct WordTranslationLookupView_Previews: PreviewProvider {
    static var previews: some View {
        WordTranslationLookupView(word: "चश्मा") {_ in}
    }
}
