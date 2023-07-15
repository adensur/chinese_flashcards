//
//  Exercise.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 08/06/2023.
//

import Foundation

let learningLevels = ["1m", "6m", "12m", "16m", "20m", "30m", "1h", "2h", "3h", "4h"]
let repeatingLevels = ["1d", "2d", "3d", "4d", "6d", "8d", "12d", "18d", "24d", "30d", "45d", "60d"]
let repeatingAfterMistakeLevels = ["1m", "6m", "12m", "16m", "20m", "30m", "1h", "2h", "3h", "4h"]

// simple exercise. Front and back text, no value checking - just turning the card over
class Card: Codable, ObservableObject, Identifiable {
    let id: Int
    @Published var frontText: String
    @Published var backText: String
    var creationDate: Date
    var lastRepetition: Date = Date(timeIntervalSince1970: 0)
    var learningStage: LearningStage = .New
    init(frontText: String, backText: String, id: Int, creationDate: Date) {
        self.frontText = frontText
        self.backText = backText
        self.id = id
        self.creationDate = creationDate
    }
    enum CodingKeys: CodingKey {
        case id, frontText, backText, creationDate, lastRepetition, learningStage
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(frontText, forKey: .frontText)
        try container.encode(backText, forKey: .backText)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(lastRepetition, forKey: .lastRepetition)
        try container.encode(learningStage, forKey: .learningStage)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        frontText = try container.decode(String.self, forKey: .frontText)
        backText = try container.decode(String.self, forKey: .backText)
        creationDate = try container.decode(Date.self, forKey: .creationDate)
        lastRepetition = try container.decode(Date.self, forKey: .lastRepetition)
        learningStage = try container.decode(LearningStage.self, forKey: .learningStage)
    }
    
    func consumeAnswer(difficulty: Difficulty) {
        self.learningStage = getNextStage(learningStage: self.learningStage, difficulty: difficulty)
        lastRepetition = Date()
    }
    
    // when would the next repetition be if we press a button with certain difficulty
    func getNextRepetitionTooltip(difficulty: Difficulty) -> String{
        let nextStage = getNextStage(learningStage: self.learningStage, difficulty: difficulty)
        return encodeTimeInterval(timeInterval: getRepetitionInterval(learningStage: nextStage))
    }
    
    // when will the next repetition be for current card level
    func getNextRepetition() -> Date {
        let interval = getRepetitionInterval(learningStage: self.learningStage)
        // print("Calculated card interval for \(frontText): \(interval) seconds")
        let nextRepetition: Date = lastRepetition + interval
        // print("Next repetition in : \(nextRepetition.timeIntervalSince(Date()))")
        return nextRepetition
    }
    
    func formattedCreationDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let formattedDate = dateFormatter.string(from: creationDate)

        return formattedDate
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

func getNextStage(learningStage: LearningStage, difficulty: Difficulty) -> LearningStage {
    switch learningStage {
    case .New:
        switch difficulty {
        case .Again:
            return .Learning(0)
        case .Hard:
            return .Learning(0)
        case .Good:
            return .Learning(1)
        case .Easy:
            return .Repeating(0)
        }
    case .Learning(let level):
        switch difficulty {
        case .Again:
            return .Learning(0)
        case .Hard:
            return learningStage
        case .Good:
            let newLevel = level + 1
            if newLevel >= learningLevels.count {
                return .Repeating(0)
            } else {
                return .Learning(newLevel)
            }
        case .Easy:
            return .Repeating(0)
        }
    case .Repeating(let level):
        switch difficulty {
        case .Again:
            return .RepeatingAfterMistake(0)
        case .Hard:
            return learningStage
        case .Good:
            let newLevel = level + 1
            if newLevel >= repeatingLevels.count {
                return .Learned
            } else {
                return .Repeating(newLevel)
            }
        case .Easy:
            let newLevel = level + 2
            if newLevel >= repeatingLevels.count {
                return .Learned
            } else {
                return .Repeating(newLevel)
            }
        }
    case .RepeatingAfterMistake(let level):
        switch difficulty {
        case .Again:
            return .RepeatingAfterMistake(0)
        case .Hard:
            return learningStage
        case .Good:
            let newLevel = level + 1
            if newLevel >= repeatingAfterMistakeLevels.count {
                return .Repeating(0)
            } else {
                return .RepeatingAfterMistake(newLevel)
            }
        case .Easy:
            return .Repeating(0)
        }
    case .Learned:
        return .Learned
    }
}

func getRepetitionInterval(learningStage: LearningStage) -> TimeInterval {
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


func encodeTimeInterval(timeInterval: TimeInterval) -> String {
    if timeInterval < 60.0 {
        return "\(Int(timeInterval))s"
    }
    let timeIntervalMinutes = timeInterval / 60
    if timeIntervalMinutes < 60 {
        return "\(Int(timeIntervalMinutes))m"
    }
    let timeIntervalHours = timeIntervalMinutes / 60
    if timeIntervalHours < 24 {
        return "\(Int(timeIntervalHours))h"
    }
    let timeIntervalDays = timeIntervalHours / 24
    return "\(Int(timeIntervalDays))d"
}

func parseTimeInterval(timeInterval: String) throws -> TimeInterval {
    let suffix = timeInterval.last!
    let prefix = String(timeInterval.prefix(timeInterval.count - 1))
    let unit: TimeInterval
    if suffix == "m" {
        unit = 60.0
    } else if suffix == "h" {
        unit = 3600.0
    } else if suffix == "d" {
        unit = 86400.0
    } else if suffix == "s" {
        unit = 1.0
    } else {
        throw fatalError("Unexpected timeinterval suffix: \(suffix)")
    }
    let value = Double(prefix)!
    return value * unit
}
