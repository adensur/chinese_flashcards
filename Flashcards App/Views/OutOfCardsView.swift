//
//  OutOfCardsView.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 11/07/2023.
//

import SwiftUI

struct OutOfCardsView: View {
    @Binding var nextDate: Date
    var callback: () -> Void
    @State private var nextInterval: TimeInterval = 0
    // timer to do periodic refreshes when the user doesn't do anything
    let timer = Timer.publish(every: 1, tolerance: 0.5, on: .main, in: .common).autoconnect()
    var body: some View {
        Group {
            Spacer()
            Text("Out of cards for now! Next repetition in: \(encodeTimeInterval(timeInterval: self.nextInterval))")
                .onReceive(timer) { _ in
                    self.nextInterval = self.nextDate.timeIntervalSinceNow
                    if self.nextInterval < 0 {
                        callback()
                    }
                }
            Spacer()
        }.onAppear {
            nextInterval = self.nextDate.timeIntervalSinceNow
        }
    }
}

func TomorrowDate() -> Date {
    var dateComponents = DateComponents()
    dateComponents.day = 1
    let tomorrowDate = Calendar.current.date(byAdding: dateComponents, to: Date())!
    return tomorrowDate
}

struct OutOfCardsView_Previews: PreviewProvider {
    static var previews: some View {
        OutOfCardsView(nextDate: .constant(TomorrowDate())) {}
    }
}
