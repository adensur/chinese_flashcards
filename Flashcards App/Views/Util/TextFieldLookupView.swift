//
//  TextFieldLookupView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 19/08/2023.
//

import SwiftUI

struct TextFieldLookupView: View {
    @Binding var text: String
    var lookupText: String
    var lookupAvailable: Bool {
        get {
            return !lookupText.isEmpty
        }
    }
    @State private var loading = false
    @State var detailsPresented = false
    @State private var translations: [Detail] = []
    var body: some View {
        HStack {
            TextField("Back Text", text: $text)
                .autocapitalization(.none)
            Spacer()
            if loading {
                ProgressView()
            }
            else {
                Group {
                    Text("lookup ")
                    Image(systemName: "chevron.right.2")
                }
                .foregroundColor(lookupAvailable ? .accentColor : .secondary)
                .contentShape(Rectangle())
                .onTapGesture {
                    if !lookupAvailable {
                        return
                    }
                    loading = true
                    Task {
                        translations = await getTranslation(for: lookupText, lang: "hi")
                        loading = false
                        detailsPresented = true
                    }
                }
            }
        }
        .navigationDestination(isPresented: $detailsPresented) {
            WordTranslationLookupView(translations: translations) {detail in
                text = detail.word
            }
        }
    }
}

struct TextFieldLookupView_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldLookupView(text: .constant(""), lookupText: "मछली")
    }
}
