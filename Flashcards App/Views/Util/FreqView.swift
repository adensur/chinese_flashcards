//
//  FreqView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 25/08/2023.
//

import SwiftUI

struct FreqView: View {
    var freq: Int
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<3) {i in
                Image(systemName: "square.fill")
                    .foregroundColor(3 - i >= freq ? .accentColor : .secondary)
                    .imageScale(.small)
            }
        }
    }
}

struct FreqView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ForEach(1..<4) {freq in
                HStack {
                    Text("Some Text")
                    FreqView(freq: freq)
                }
            }
        }
    }
}
