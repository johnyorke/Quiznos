//
//  Round.swift
//  Quiznos
//
//  Created by John Yorke on 17/01/2017.
//  Copyright © 2017 John Yorke. All rights reserved.
//

import Foundation

struct Round {
    let question: Question
    let answers: [Answer]
    
    func indexOfCorrectAnswer() -> Int? {
        for x in 0..<answers.count {
            let answer = answers[x]
            if answer.isCorrect { return x }
        }
        return nil
    }
}
