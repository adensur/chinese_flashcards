//
//  CorrectedTextView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 10/08/2023.
//

import SwiftUI

func splitText(text: String, correctText: String) -> (textPrefix: String, textMiddle: String, textSuffix: String, correctPrefix: String, correctMiddle: String, correctSuffix: String) {
    var i = text.startIndex
    var j = correctText.startIndex
    
    var start1 = text.startIndex
    var end1 = text.endIndex
    var start2 = correctText.startIndex
    var end2 = correctText.endIndex
    while i < text.endIndex && j < correctText.endIndex && text[i] == correctText[j] {
        i = text.index(after: i)
        j = correctText.index(after: j)
    }
    start1 = i
    start2 = j
    
    if text.isEmpty {
        return (
            textPrefix: "",
            textMiddle: "",
            textSuffix: "",
            correctPrefix: "",
            correctMiddle: correctText,
            correctSuffix: ""
        )
    }
    
    if correctText.isEmpty {
        return (
            textPrefix: "",
            textMiddle: text,
            textSuffix: "",
            correctPrefix: "",
            correctMiddle: "",
            correctSuffix: ""
        )
    }
    
    i = text.index(before: text.endIndex)
    j = correctText.index(before: correctText.endIndex)
    
    while i >= text.startIndex && j >= correctText.startIndex && text[i] == correctText[j] {
        i = text.index(before: i)
        j = correctText.index(before: j)
    }
    end1 = text.index(after: i)
    end2 = correctText.index(after: j)
    return (
        textPrefix: String(text[text.startIndex..<start1]),
        textMiddle: String(text[start1..<end1]),
        textSuffix: String(text[end1..<text.endIndex]),
        correctPrefix: String(correctText[text.startIndex..<start2]),
        correctMiddle: String(correctText[start2..<end2]),
        correctSuffix: String(correctText[end2..<correctText.endIndex])
    )
}

struct CorrectedTextView: View {
    var text: String
    var correctText: String
    var highlightedText: AttributedString {
        let tuple = splitText(text: text, correctText: correctText)
        
        let prefix = AttributedString(tuple.textPrefix)
        var middle = AttributedString(tuple.textMiddle)
        let suffix = AttributedString(tuple.textSuffix)
        middle.backgroundColor = .red
        return prefix + middle + suffix
    }
    
    var highlightedCorrectText: AttributedString {
        let tuple = splitText(text: text, correctText: correctText)
        
        let prefix = AttributedString(tuple.correctPrefix)
        var middle = AttributedString(tuple.correctMiddle)
        let suffix = AttributedString(tuple.correctSuffix)
        middle.backgroundColor = .green
        return prefix + middle + suffix
    }
    
    var body: some View {
        VStack {
            Text(highlightedText)
            Image(systemName: "arrow.down")
            Text(highlightedCorrectText)
        }
    }
}

struct CorrectedTextView_Previews: PreviewProvider {
    static var previews: some View {
        CorrectedTextView(text: "प्रेमीका", correctText: "प्रेमिका")
    }
}
