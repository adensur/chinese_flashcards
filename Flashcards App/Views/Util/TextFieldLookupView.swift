//
//  TextFieldLookupView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 19/08/2023.
//

import SwiftUI

struct TextFieldLookupView: View {
    @Binding var text: String
    @Binding var wordType: EWordType
    var lookupText: String
    var lookupAvailable: Bool {
        get {
            return !lookupText.isEmpty
        }
    }
    @State private var loading = false
    @State var detailsPresented = false
    @State var errorPresented = false
    @State private var translations: [Detail] = []
    var translateFromLanguage: ELanguage
    var translateToLanguage: ELanguage
    var body: some View {
        ZStack {
            // we use deprecated NavigationLink(isActive: ...) api
            // because of the .destination bug that causes weird navigation stack behaviour
            NavigationLink("this should not be seen", isActive: $detailsPresented) {
                WordTranslationLookupView(word: lookupText, translations: translations) {detail in
                    text = detail.word
                    wordType = detail.type
                }
            }.opacity(0)
            HStack {
                TextField("Back Text", text: $text)
                    .autocapitalization(.none)
                Spacer()
                if loading {
                    ProgressView()
                } else {
                    Group {
                        Text((errorPresented && lookupAvailable) ? "retry": "lookup")
                        Image(systemName: "chevron.right.2")
                    }
                    .foregroundColor(lookupAvailable ? (errorPresented ? .red : .accentColor) : .secondary)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !lookupAvailable {
                            return
                        }
                        loading = true
                        Task {
                            let translations = await getTranslation(for: lookupText, langFrom: translateFromLanguage.rawValue, langTo: translateToLanguage.rawValue)
                            if let translations = translations {
                                self.translations = translations
                                detailsPresented = true
                            } else {
                                errorPresented = true
                            }
                            loading = false
                        }
                    }
                }
            }
        }
    }
}

struct TextFieldLookupView_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldLookupView(text: .constant(""), wordType: .constant(.noun), lookupText: "मछली", translateFromLanguage: .Hindi, translateToLanguage: .English)
    }
}
