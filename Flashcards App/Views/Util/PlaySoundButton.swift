//
//  PlaySoundButton.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 04/08/2023.
//

import SwiftUI
import AVFoundation

var audioPlayer : AVAudioPlayer?


struct PlaySoundButton<Content: View>: View {
    let audioData: Data
    @ViewBuilder var content: Content
    var body: some View {
        content
            .onTapGesture {
                audioPlayer = try? AVAudioPlayer(data: audioData)
                audioPlayer?.play()
            }
    }
}

extension Card {
    func playSound() {
        if let data = self.audioData {
            audioPlayer = try? AVAudioPlayer(data: data)
            audioPlayer?.play()
        }
    }
}

struct PlaySoundButton_Previews: PreviewProvider {
    static var previews: some View {
        PlaySoundButton(audioData: defaultVocab.cards["आगे"]!.audioData!) {
            Image(systemName: "edit")
        }
    }
}
