//
//  Parser.swift
//  Quiznos
//
//  Created by John Yorke on 17/01/2017.
//  Copyright © 2017 John Yorke. All rights reserved.
//

import Foundation

class Parser {
    
    func rounds(fromDictionary dictionary: [String : AnyObject]) -> [Round] {
        
        var rounds = [Round]()
        
        let resultsArray = dictionary["results"] as! [[String : AnyObject]]
        
        for result in resultsArray {
            // Get the question
            let questionString = result["question"] as! String
            let question = Question(title: questionString.html2String)
            
            // Set up array for answers
            var answers = [Answer]()
            
            // Get correct answer
            let correctAnswerString = result["correct_answer"] as! String
            let correctAnswer = Answer(title: correctAnswerString.html2String, isCorrect: true)
            
            // Cycle through multiple choices
            let arrayOfIncorrectAnswers = result["incorrect_answers"] as! [String]
            for string in arrayOfIncorrectAnswers {
                let wrongAnswer = Answer(title: string.html2String, isCorrect: false)
                answers.append(wrongAnswer)
            }
            
            // Insert correct answer at random index
            let randomIndex = Int(arc4random_uniform(UInt32(answers.count)))
            answers.insert(correctAnswer, at: randomIndex)
            
            // Create a round and add it to array
            let round = Round(question: question, answers: answers)
            rounds.append(round)
        }
        
        return rounds
    }
    
}
