//
//  SuggestView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 17/07/2023.
//

import SwiftUI

extension String {
    func hasUnicodePrefx(_ prefix: String) -> Bool {
        // Get the Unicode scalar views of both strings
        let prefixScalars = prefix.unicodeScalars
        let stringScalars = self.unicodeScalars
        // Check if the prefix is longer than the original string
        if prefixScalars.count > stringScalars.count {
            return false
        }
        
        // Iterate through both scalars to check for the prefix
        for (prefixScalar, stringScalar) in zip(prefixScalars, stringScalars) {
            // If any pair of code points is not equal, it's not a prefix
            if prefixScalar != stringScalar {
                return false
            }
        }
        
        // If we reach this point, the prefix is a valid prefix of the string
        return true
    }
}


struct SuggestView: View {
    @Binding var inputText: String
    var vocab: Vocab
    let callback: (VocabCard) -> Void
    @State private var filteredTexts: [String] = []
    
    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filteredTexts, id: \.self) { textSearched in
                    HStack {
                        Text(textSearched)
                        if let pinyin = vocab.cards[textSearched]!.pinyin {
                            Text(pinyin)
                        }
                        Spacer()
                        Text(vocab.cards[textSearched]!.backText)
                        if let freq = vocab.cards[textSearched]!.frequency {
                            FreqView(freq: freq)
                        }
                    }
                        .padding(.vertical, 20)
                        .frame(minWidth: 0,
                               maxWidth: .infinity,
                               minHeight: 0,
                               maxHeight: 30,
                               alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture(perform: {
                            inputText = textSearched
                            self.callback(vocab.cards[textSearched]!)
                        })
                    Divider()
                        .padding(.horizontal, 10)
                }
            }
        }
        .onChange(of: inputText) {inputText in
            print("Computing filtered texts!")
            filteredTexts = vocab.findMatches(inputText)
        }
        .onAppear {
            print("Initialising filtered texts!")
            filteredTexts = vocab.cards.keys.filter {vocabString in
                vocabString.hasUnicodePrefx(inputText.precomposedStringWithCanonicalMapping)
            }
        }
//        .background(Color.white)
//        .cornerRadius(15)
//        .foregroundColor(Color(.black))
//        .frame(maxWidth: .infinity)
        .frame(maxHeight: 30 * CGFloat( (filteredTexts.count > 5 ? 5: filteredTexts.count)))
//        .shadow(radius: 4)
        .padding(.horizontal, 25)
    }
}

struct SuggestView_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper("आ") {text in
            VStack {
                SuggestView(inputText: text, vocab: previewVocab) { vocabCard in
                    print("Matched vocab card: ", vocabCard)
                }
            }
            
        }
    }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content

    public var body: some View {
        content($value)
    }

    public init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        self._value = State(wrappedValue: value)
        self.content = content
    }
}
