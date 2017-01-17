//
//  ViewPresenter.swift
//  Quiznos
//
//  Created by John Yorke on 17/01/2017.
//  Copyright © 2017 John Yorke. All rights reserved.
//

import Foundation
import UIKit

protocol PresenterProtocol {
    init(view: ViewProtocol)
    func startGame()
    func handleAnswer(atIndex index: Int)
}

class ViewPresenter: PresenterProtocol {
    
    unowned let view: ViewProtocol
    var rounds: [Round]!
    var score: Int = 0
    var currentRoundIndex: Int = 0
    var currentDifficulty = Difficulty.easy
    let api = QuizAPI()
    
    required init(view: ViewProtocol) {
        self.view = view
    }
    
    func startGame() {
        currentRoundIndex = 0
        score = 0
        let url = URL(string: "https://opentdb.com/api.php?amount=10&category=15&difficulty=\(currentDifficulty.rawValue)&type=multiple")
        api.loadRounds(fromUrl: url!) { (rounds) in
            self.rounds = rounds
            self.view.updateScoreLabel(withScore: self.score,
                                       numberOfRounds: rounds.count,
                                       difficulty: self.currentDifficulty.rawValue)
            self.view.show(round: self.rounds[self.currentRoundIndex])
            self.view.updatePageControl(withIndex: self.currentRoundIndex,
                                        numberOfRounds: self.rounds.count)
        }
    }
    
    func handleAnswer(atIndex index: Int) {
        let round = rounds[currentRoundIndex]
        let correctAnswerIndex = round.indexOfCorrectAnswer()
        if correctAnswerIndex == index {
            score += 1
        }
        
        self.view.updateScoreLabel(withScore: self.score,
                                   numberOfRounds: self.rounds.count,
                                   difficulty: self.currentDifficulty.rawValue)
        
        currentRoundIndex += 1
        
        if self.currentRoundIndex < rounds.count {
            self.view.updatePageControl(withIndex: self.currentRoundIndex,
                                        numberOfRounds: self.rounds.count)
            self.view.show(round: self.rounds[self.currentRoundIndex])
        } else {
            self.currentDifficulty = self.currentDifficulty.nextDifficulty
            let restartAction = UIAlertAction(title: "Load More Questions",
                                              style: .default,
                                              handler: { (action) in
                self.startGame()
            })
            view.showAlert(withTitle: "Congratulations!",
                           message: "You scored \(score) out of \(rounds.count).",
                actions: [restartAction])
        }
    }
}
