//
//  AddCardView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 12/06/2023.
//

import SwiftUI

private let grey = Color(red: 0.95, green: 0.95, blue: 0.96)

struct MyFormModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color.white)
            .padding(10)
            .cornerRadius(15)
            .background(grey)
    }
}

extension View {
    func myFormStyle() -> some View {
        modifier(MyFormModifier())
    }
}

struct MyForm2<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        HStack {
            Spacer()
            VStack {
                content
                Spacer()
            }
            Spacer()
        }
        .background(grey)
    }
}




struct AddCardView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var frontText: String = ""
    @State private var backText: String = ""
    @State var showSuggestions: Bool = false
    @State var showSuggestions2: Bool = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            MyForm {
                MySection {
                    TextField("Front Text", text: $frontText)
                        .focused($isFocused)
                        .onChange(of: isFocused) {_ in
                            showSuggestions = false
                            showSuggestions2 = true
                            print("focus changed! show suggestions is ", showSuggestions)
                        }
                        .onChange(of: frontText) { _ in
                            print("onChange processing! ", Date())
                            if showSuggestions2 {
                                showSuggestions = true
                            }
                            showSuggestions2 = true
                        }
                        .overlay(alignment: .top) {
                            if showSuggestions {
                                SuggestView(editing: $showSuggestions, editing2: $showSuggestions2, inputText:$frontText) {vocabCard in
                                    backText = vocabCard.backText
                                }
                                .offset(y: 30)
                                .zIndex(100)
                            }
                        }
                } header: {
                    Text("FrontText")
                }.zIndex(1)
                MySection {
                    TextField("Back Text", text: $backText)
                        .zIndex(0)
                } header: {
                    Text("Back Text")
                        .zIndex(0)
                }
            }
            .onTapGesture {
                print("OnTapGesture! Disabling focus. Was: ", isFocused)
                isFocused = false
            }
        }.navigationTitle("Add Flashcard")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    // Perform save action here
                    defaultDeck.addCard(frontText: frontText, backText: backText)
                    presentationMode.wrappedValue.dismiss()
                }
            )
    }
}

struct AddCardView_Previews: PreviewProvider {
    static var previews: some View {
        AddCardView()
    }
}
