//
//  SuggestView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 17/07/2023.
//

import SwiftUI

struct SuggestView: View {
    @Binding var inputText: String
    let callback: (VocabCard) -> Void
    
    private var filteredTexts: Binding<[String]> { Binding (
        get: {
            return defaultVocab.cards.keys.filter { $0.contains(inputText) && $0.prefix(1) == inputText.prefix(1) } },
        set: { _ in })
    }
    
    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filteredTexts.wrappedValue, id: \.self) { textSearched in
                    Text(textSearched)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .frame(minWidth: 0,
                               maxWidth: .infinity,
                               minHeight: 0,
                               maxHeight: 30,
                               alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture(perform: {
                            inputText = textSearched
                            self.callback(defaultVocab.cards[textSearched]!)
                        })
                    Divider()
                        .padding(.horizontal, 10)
                }
            }
        }.background(Color.white)
        .cornerRadius(15)
        .foregroundColor(Color(.black))
        .ignoresSafeArea()
        .frame(maxWidth: .infinity)
        .frame(height: 40 * CGFloat( (filteredTexts.wrappedValue.count > 10 ? 10: filteredTexts.wrappedValue.count)))
        .shadow(radius: 4)
        .padding(.horizontal, 25)
    }
}

struct SuggestView_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper("आ") {text in
            VStack {
                TextField("Title", text: text)
                SuggestView(inputText: text) { vocabCard in
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
