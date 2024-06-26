//
//  SoundLookupView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 20/08/2023.
//

import SwiftUI

struct SoundLookupView: View {
    var lookupText: String
    @Binding var audioData: Data?
    @State private var loading = false
    var lookupAvailable: Bool {
        get {
            return !lookupText.isEmpty
        }
    }
    @State var errorPresented = false
    var languageToGetSoundFor: ELanguage
    var body: some View {
        HStack {
            Image(systemName: "speaker.wave.3.fill")
                .foregroundColor(audioData == nil ? .secondary : .accentColor)
            .onTapGesture {
                if let data = audioData {
                    playSound(data: data)
                }
            }
            Spacer()
            if loading {
                ProgressView()
            } else {
                Group {
                    Text((errorPresented && lookupAvailable) ? "retry": "get sound")
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
                        print("Started getting sound!", Date())
                        audioData = await getSound(for: lookupText, lang: languageToGetSoundFor.rawValue)
                        print("Got sound!", Date())
                        if audioData == nil {
                            errorPresented = true
                        }
                        if let data = audioData {
                            playSound(data: data)
                        }
                        loading = false
                    }
                }
            }
        }
    }
}

struct SoundLookupView_Previews: PreviewProvider {
    static var previews: some View {
        SoundLookupView(lookupText: "मछली", audioData: .constant(nil), languageToGetSoundFor: .Hindi)
    }
}
