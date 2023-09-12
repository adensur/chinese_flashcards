//
//  LanguageAwareTextField.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 12/09/2023.
//

import Foundation
import SwiftUI
import UIKit

struct LanguageAwareTextField: View {
    var titleKey: String
    var text: Binding<String>
    var language: ELanguage
    var body: some View {
        SpecificLanguageTextFieldView(placeHolder: titleKey, text: text, language: language.bcp47Code)
            .environment(\.layoutDirection, language.isRtl ? .rightToLeft : .leftToRight)
            .flipsForRightToLeftLayoutDirection(true)
            .keyboardType(.default)
    }
    
    init(_ titleKey: String, text: Binding<String>, language: ELanguage) {
        self.titleKey = titleKey
        self.text = text
        self.language = language
    }
}

class SpecificLanguageTextField: UITextField {
    var language: String? {
        didSet {
            if self.isFirstResponder {
                self.resignFirstResponder();
                self.becomeFirstResponder();
            }
        }
    }
    
    override var textInputMode: UITextInputMode? {
        if let language = self.language {
            for inputMode in UITextInputMode.activeInputModes {
                if let inputModeLanguage = inputMode.primaryLanguage, inputModeLanguage == language {
                    return inputMode
                }
            }
        }
        return super.textInputMode
    }
}

struct SpecificLanguageTextFieldView: UIViewRepresentable {
    
    let placeHolder: String
    @Binding var text: String
    var language: String = "en-US"
    
    func makeUIView(context: Context) -> UITextField{
        let textField = SpecificLanguageTextField(frame: .zero)
        textField.placeholder = self.placeHolder
        textField.text = self.text
        textField.language = self.language
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
    }
    
}

#Preview {
    LanguageAwareTextField("InputText", text: .constant("שלום"), language: .Hebrew)
}
