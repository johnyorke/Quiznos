//
//  ViewController.swift
//  Quiznos
//
//  Created by John Yorke on 16/01/2017.
//  Copyright © 2017 John Yorke. All rights reserved.
//

import UIKit

struct Question {
    let title: String
}

struct Answer {
    let title: String
    let isCorrect: Bool
}

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

class ViewController: UIViewController {
    
    enum Difficulty: String {
        case easy = "easy"
        case medium = "medium"
        case hard = "hard"
        
        var nextDifficulty: Difficulty {
            switch self {
            case .easy:
                return .medium
            case .medium:
                return .hard
            case .hard:
                return .easy
            }
        }
    }
    
    var rounds: [Round]!
    var score: Int = 0
    var currentRoundIndex: Int = 0
    var currentDifficulty = Difficulty.easy
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerOneButton: UIButton!
    @IBOutlet weak var answerButtonTwo: UIButton!
    @IBOutlet weak var answerButtonThree: UIButton!
    @IBOutlet weak var answerButtonFour: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        startGame(atDifficulty: Difficulty.easy)
    }
    
    func startGame(atDifficulty difficulty: Difficulty) {
        loadJson(forDifficulty: difficulty.rawValue) { (dictionary) in
            self.rounds = self.getRounds(fromJSONDictionary: dictionary)
            self.updateTheViews()
        }
    }
    
    func loadJson(forDifficulty difficulty: String, completion: @escaping ([String : AnyObject]) -> Void) {
        let url = URL(string: "https://opentdb.com/api.php?amount=10&category=15&difficulty=\(difficulty)&type=multiple")
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String : AnyObject]
                completion(json)
            } catch {
                self.questionLabel.text = "Uh oh. An error occured desirialising JSON"
            }
            }.resume()
    }
    
    func getRounds(fromJSONDictionary dictionary: [String : AnyObject]) -> [Round] {
        
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
    
    func updateTheViews() {
        DispatchQueue.main.async {
            // Update the current score label
            self.scoreLabel.text = "Current Score - \(self.score)/\(self.rounds.count) (\(self.currentDifficulty.rawValue.capitalized))"
            self.pageControl.numberOfPages = self.rounds.count
            
            // Make sure you have questions left in game
            if self.currentRoundIndex < self.rounds.count {
                self.showRound()
            } else {
                self.endTheGame()
            }
        }
    }
    
    func showRound() {
        pageControl.currentPage = currentRoundIndex
        let round = rounds[currentRoundIndex]
        questionLabel.text = round.question.title
        let buttons = [answerOneButton,answerButtonTwo,answerButtonThree,answerButtonFour]
        for x in 0..<buttons.count {
            let button = buttons[x]
            button?.tag = x
            let answer = round.answers[x]
            button?.setTitle(answer.title, for: .normal)
            button?.addTarget(self, action: #selector(answerButtonPressed(button:)), for: .touchUpInside)
        }
    }
    
    func endTheGame() {
        let vc = UIAlertController(title: "Congratulations!", message: "You scored \(score) out of \(rounds.count).", preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Load More Questions", style: .default, handler: { (action) in
            self.currentDifficulty = self.currentDifficulty.nextDifficulty
            self.startGame(atDifficulty: self.currentDifficulty)
        })
        vc.addAction(restartAction)
        show(vc, sender: nil)
        currentRoundIndex = 0
        score = 0
    }
    
    func answerButtonPressed(button: UIButton) {
        let round = rounds[currentRoundIndex]
        let correctAnswerIndex = round.indexOfCorrectAnswer()
        if correctAnswerIndex == button.tag {
            score += 1
        }
        currentRoundIndex += 1
        updateTheViews()
    }
}

extension String {
    var html2String: String {
        guard let data = data(using: .utf8) else { return "" }
        do {
            return try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil).string
        } catch {
            return ""
        }
    }
}
