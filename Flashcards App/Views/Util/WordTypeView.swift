//
//  WordTypeView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 26/08/2023.
//

import SwiftUI

struct WordTypeView: View {
    var type: EWordType
    var body: some View {
        Text("\(type.toString())")
            .font(.footnote)
            .foregroundColor(.secondary)
    }
}

struct WordTypeView_Previews: PreviewProvider {
    static var previews: some View {
        WordTypeView(type: .noun)
    }
}
