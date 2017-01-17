//
//  ViewController.swift
//  Quiznos
//
//  Created by John Yorke on 16/01/2017.
//  Copyright © 2017 John Yorke. All rights reserved.
//

import UIKit

protocol ViewProtocol: class {
    func show(round: Round)
    func updateScoreLabel(withScore score: Int, numberOfRounds: Int, difficulty: String)
    func showAlert(withTitle title: String, message: String, actions: [UIAlertAction])
    func updatePageControl(withIndex index: Int, numberOfRounds: Int)
}

class ViewController: UIViewController, ViewProtocol {
    
    var presenter: PresenterProtocol!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerOneButton: UIButton!
    @IBOutlet weak var answerButtonTwo: UIButton!
    @IBOutlet weak var answerButtonThree: UIButton!
    @IBOutlet weak var answerButtonFour: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ViewPresenter(view: self)
        presenter.startGame()
    }
    
    func show(round: Round) {
        DispatchQueue.main.async {
            self.questionLabel.text = round.question.title
            let buttons = [
                self.answerOneButton,
                self.answerButtonTwo,
                self.answerButtonThree,
                self.answerButtonFour]
            
            for x in 0..<buttons.count {
                let button = buttons[x]
                button?.tag = x
                let answer = round.answers[x]
                button?.setTitle(answer.title, for: .normal)
                button?.addTarget(self, action: #selector(self.answerButtonPressed(button:)), for: .touchUpInside)
            }
        }
        
    }
    
    func updateScoreLabel(withScore score: Int, numberOfRounds: Int, difficulty: String) {
        DispatchQueue.main.async {
            self.scoreLabel.text = "Current Score - \(score)/\(numberOfRounds) (\(difficulty.capitalized))"
        }
    }
    
    func updatePageControl(withIndex index: Int, numberOfRounds: Int) {
        DispatchQueue.main.async {
            self.pageControl.numberOfPages = numberOfRounds
            self.pageControl.currentPage = index
        }
    }
    
    func showAlert(withTitle title: String, message: String, actions: [UIAlertAction]) {
        DispatchQueue.main.async {
            let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
            for action in actions {
                vc.addAction(action)
            }
            self.show(vc, sender: nil)
        }
    }
    
    func answerButtonPressed(button: UIButton) {
        presenter.handleAnswer(atIndex: button.tag)
    }
}
