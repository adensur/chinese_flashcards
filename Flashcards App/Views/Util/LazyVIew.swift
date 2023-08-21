//
//  LazyVIew.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 21/08/2023.
//

import SwiftUI

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(@ViewBuilder _ build: @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
