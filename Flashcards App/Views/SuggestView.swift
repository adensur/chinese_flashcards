//
//  SuggestView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 17/07/2023.
//

import SwiftUI
import Combine

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

extension Publishers {
    // 1.
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        // 2.
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map {
                print("willShow! height: \($0.keyboardHeight)")
                return $0.keyboardHeight
            }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        // 3.
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

struct KeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(Publishers.keyboardHeight) {
                self.keyboardHeight = $0
                print("Keyboard height: \(keyboardHeight)")
            }
    }
}

extension View {
    func keyboardAdaptive() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive())
    }
}


struct SuggestView: View {
    @Binding var inputText: String
    let callback: (VocabCard) -> Void
    
    private var filteredTexts: Binding<[String]> { Binding (
        get: {
            return defaultVocab.cards.keys.filter {vocabString in
                vocabString.hasUnicodePrefx(inputText)
            }
        },
        set: { _ in })
    }
    
    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filteredTexts.wrappedValue, id: \.self) { textSearched in
                    HStack {
                        Text(textSearched)
                        Spacer()
                        Text(defaultVocab.cards[textSearched]!.backText)
                    }
//                        .padding(.horizontal, 20)
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
        }
//        .background(Color.white)
//        .cornerRadius(15)
//        .foregroundColor(Color(.black))
//        .frame(maxWidth: .infinity)
        .frame(maxHeight: 40 * CGFloat( (filteredTexts.wrappedValue.count > 10 ? 10: filteredTexts.wrappedValue.count)))
//        .shadow(radius: 4)
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
