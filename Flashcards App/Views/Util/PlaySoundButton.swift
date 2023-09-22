//
//  PlaySoundButton.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 04/08/2023.
//

import SwiftUI
import AVFoundation

var audioPlayer : AVAudioPlayer?

fileprivate func playSoundInner(data: Data) {
    audioPlayer = try? AVAudioPlayer(data: data)
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback)
    } catch(let error) {
        print(error.localizedDescription)
    }
    audioPlayer?.play()
}

struct PlaySoundButton<Content: View>: View {
    let audioData: Data
    @ViewBuilder var content: Content
    var body: some View {
        content
            .onTapGesture {
                playSoundInner(data: audioData)
            }
    }
}

func playSound(data: Data) {
    playSoundInner(data: data)
}

extension Card {
    func playSound() {
        if let deck = self.deck {
            if deck.disableSound {
                return
            }
        }
        if let data = self.audioData {
            playSoundInner(data: data)
        }
    }
}

struct PlaySoundButton_Previews: PreviewProvider {
    static var previews: some View {
        PlaySoundButton(audioData: previewVocab.cards["आगे"]!.audioData!) {
            Image(systemName: "edit")
        }
    }
}
