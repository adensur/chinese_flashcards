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
    var autocorrectionDisabled = false
    var onSubmit: () -> Void
    var body: some View {
//        TextField(titleKey, text: text)
        SpecificLanguageTextFieldView(placeHolder: titleKey, text: text, language: language.bcp47Code, autocorrectionDisabled: autocorrectionDisabled) {
            onSubmit()
        }
            .environment(\.layoutDirection, language.isRtl ? .rightToLeft : .leftToRight)
            .flipsForRightToLeftLayoutDirection(true)
            .keyboardType(.default)
            .autocorrectionDisabled()
    }
    
    init(_ titleKey: String, text: Binding<String>, language: ELanguage, autocorrectionDisabled: Bool = false, onSubmit: @escaping () -> Void) {
        self.titleKey = titleKey
        self.text = text
        self.language = language
        self.onSubmit = onSubmit
        self.autocorrectionDisabled = autocorrectionDisabled
    }
}

let enCompatibleEngs = Set(["fr", "de", "it"])

func isCompatible(availableInputMode: String, targetLang: String) -> Bool {
    if (availableInputMode == "en") {
        if enCompatibleEngs.contains(targetLang) {
            return true
        }
    }
    return false
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
            // first try to find exact match
            for inputMode in UITextInputMode.activeInputModes {
                if let inputModeLanguage = inputMode.primaryLanguage, inputModeLanguage.prefix(2) == language.prefix(2) {
                    return inputMode
                }
            }
            // if no exact match found, look for the next best match based on compatibility matrix
            // i.e., "en" is also good for "fr"
            for inputMode in UITextInputMode.activeInputModes {
                if let inputModeLanguage = inputMode.primaryLanguage, isCompatible(availableInputMode: String(inputModeLanguage.prefix(2)), targetLang: String(language.prefix(2))) {
                    return inputMode
                }
            }
        }
        return super.textInputMode
    }
}

struct SpecificLanguageTextFieldView: UIViewRepresentable {
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: SpecificLanguageTextFieldView
        init(_ parent: SpecificLanguageTextFieldView) {
            self.parent = parent
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.onSubmit()
            textField.resignFirstResponder() // Dismiss the keyboard
            return true
        }
    }
    
    let placeHolder: String
    @Binding var text: String
    var language: String = "en-US"
    var autocorrectionDisabled = false
    var onSubmit: (() -> Void)
    func makeUIView(context: Context) -> UITextField{
        let textField = SpecificLanguageTextField(frame: .zero)
        textField.placeholder = self.placeHolder
        textField.text = self.text
        textField.language = self.language
        textField.delegate = context.coordinator
        textField.autocapitalizationType = .none
        if autocorrectionDisabled {
            textField.autocorrectionType = .no
        }
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}

#Preview {
    LanguageAwareTextField("InputText", text: .constant("שלום"), language: .Hebrew) { }
}
