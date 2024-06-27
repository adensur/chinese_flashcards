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
    var callback: ([Detail]) -> Void
    @Environment(\.dismiss) var dismiss
    @State var selection = Set<String>()
    var body: some View {
        if !translations.isEmpty {
            List {
                Section {
                    ForEach(translations) {detail in
                        HStack {
                            Text("\(detail.word)")
                            if let type = detail.type {
                                WordTypeView(type: type)
                            }
                            if let pinyin = detail.pinyin {
                                Text(pinyin)
                            }
                            Spacer()
                            if selection.contains(detail.id) {
                                Image(systemName: "checkmark")
                            }
                            if let freq = detail.freq {
                                FreqView(freq: freq)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selection.contains(detail.word) {
                                selection.remove(detail.id)
                            } else {
                                selection.insert(detail.id)
                            }
                            if translations.count == 1 {
                                // why bother user with another click in this case?
                                done()
                            }
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
            .navigationBarItems(
                trailing: Button("Done") {
                    done()
                }
                    .disabled(selection.isEmpty)
            )
        } else {
            VStack {
                Text("Sorry, no entries found for \(word)")
                Spacer()
            }
        }
    }
    
    func done() {
        let details = translations.filter {detail in
            selection.contains(detail.id)
        }
        dismiss()
        callback(details)
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
