//
//  Exercise.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 08/06/2023.
//

import Foundation

// simple exercise. Front and back text, no value checking - just turning the card over
class Card: Encodable, Decodable {
    var frontText: String
    var backText: String
    var lastRepetition: Date = Date(timeIntervalSince1970: 0)
    var learningStage: LearningStage = .New
    init(frontText: String, backText: String) {
        self.frontText = frontText
        self.backText = backText
    }
    
    static let learningLevels = ["1m", "6m", "12m", "16m", "20m", "30m", "1h", "2h", "3h", "4h"]
    static let repeatingLevels = ["1d", "2d", "3d", "4d", "6d", "8d", "12d", "18d", "24d", "30d", "45d", "60d"]
    static let repeatingAfterMistakeLevels = ["1m", "6m", "12m", "16m", "20m", "30m", "1h", "2h", "3h", "4h"]
    
    func consumeAnswer(difficulty: Difficulty) {
        // todo!
        switch learningStage {
        case .New:
            switch difficulty {
            case .Again:
                self.learningStage = .Learning(0)
            case .Hard:
                self.learningStage = .Learning(0)
            case .Good:
                self.learningStage = .Learning(1)
            case .Easy:
                self.learningStage = .Repeating(1)
            }
        case .Learning(let level):
            switch difficulty {
            case .Again:
                self.learningStage = .Learning(0)
            case .Hard:
                break
            case .Good:
                let newLevel = level + 1
                if newLevel >= Card.learningLevels.count {
                    self.learningStage = .Repeating(1)
                } else {
                    self.learningStage = .Learning(newLevel)
                }
            case .Easy:
                self.learningStage = .Repeating(1)
            }
        case .Repeating(let level):
            switch difficulty {
            case .Again:
                self.learningStage = .RepeatingAfterMistake(1)
            case .Hard:
                break
            case .Good:
                let newLevel = level + 1
                if newLevel >= Card.repeatingLevels.count {
                    self.learningStage = .Learned
                } else {
                    self.learningStage = .Repeating(newLevel)
                }
            case .Easy:
                let newLevel = level + 2
                if newLevel >= Card.repeatingLevels.count {
                    self.learningStage = .Learned
                } else {
                    self.learningStage = .Repeating(newLevel)
                }
            }
        case .RepeatingAfterMistake(let level):
            switch difficulty {
            case .Again:
                self.learningStage = .RepeatingAfterMistake(1)
            case .Hard:
                break
            case .Good:
                let newLevel = level + 1
                if newLevel >= Card.repeatingAfterMistakeLevels.count {
                    self.learningStage = .Repeating(1)
                } else {
                    self.learningStage = .RepeatingAfterMistake(newLevel)
                }
                self.learningStage = .RepeatingAfterMistake(newLevel)
            case .Easy:
                self.learningStage = .Repeating(1)
            }
        case .Learned:
            break
        }
        lastRepetition = Date()
    }
    
    func isReady() -> Bool {
        let interval = Card.getRepetitionInterval(learningStage: self.learningStage)
        print("Calculated card interval for \(frontText): \(interval) seconds")
        let nextRepetition: Date = lastRepetition + interval
        print("Next repetition in : \(nextRepetition.timeIntervalSince(Date()))")
        if lastRepetition + interval <= Date() {
            return true
        }
        return false
    }
    
    static func parseTimeInterval(timeInterval: String) throws -> TimeInterval {
        let suffix = timeInterval.last!
        let prefix = String(timeInterval.prefix(timeInterval.count - 1))
        let unit: TimeInterval
        if suffix == "m" {
            unit = 60.0
        } else if suffix == "h" {
            unit = 3600.0
        } else if suffix == "d" {
            unit = 86400.0
        } else {
            throw fatalError("Unexpected timeinterval suffix: \(suffix)")
        }
        let value = Double(prefix)!
        return value * unit
    }
    
    static func encodeTimeInterval(timeInterval: TimeInterval) -> String {
        if timeInterval < 60.0 {
            return "\(timeInterval)s"
        }
        let timeIntervalMinutes = timeInterval / 60
        if timeIntervalMinutes < 60 {
            return "\(timeIntervalMinutes)m"
        }
        let timeIntervalHours = timeIntervalMinutes / 60
        if timeIntervalHours < 24 {
            return "\(timeIntervalHours)h"
        }
        let timeIntervalDays = timeIntervalHours / 24
        return "\(timeIntervalDays)d"
    }
    
    static func getRepetitionInterval(learningStage: LearningStage) -> TimeInterval {
        switch learningStage {
        case .New:
            return TimeInterval(0)
        case .Learning(let level):
            return try! parseTimeInterval(timeInterval: learningLevels[level])
        case .Repeating(let level):
            return try! parseTimeInterval(timeInterval: repeatingLevels[level])
        case .RepeatingAfterMistake(let level):
            return try! parseTimeInterval(timeInterval: repeatingAfterMistakeLevels[level])
        case .Learned:
            return TimeInterval(0)
        }
    }
}

// New - the card was just added, with no repetitions yet
// Learning - first-day repetition, typically going from minutes to hours. Clicking "easy" on "Learning" stage or moving through all levels moves the card to "Repeating"
// Repeating - typically going from one to many days or even months. Going through all the levels brings the card to "Learned" and moves out of the deck. Making a mistake moves it to "RepeatingAfterMistake"
// RepeatingAfterMistake - repeating from minutes to hours. Clicking "easy" or going through all the levels brings the card back on the first level of "Repeating"
// Learned - the card is finished and is effectively moved out of the deck, though still available for stats
enum LearningStage: Encodable, Decodable {
case New
case Learning(Int)
case Repeating(Int)
case RepeatingAfterMistake(Int)
case Learned
}
