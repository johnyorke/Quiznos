//
//  API.swift
//  Quiznos
//
//  Created by John Yorke on 17/01/2017.
//  Copyright © 2017 John Yorke. All rights reserved.
//

import Foundation

class QuizAPI {
    
    let networkManager = NetworkManager.shared
    let parser = Parser()
    
    func loadRounds(fromUrl url: URL, completion: @escaping ([Round]) -> Void) {
        networkManager.getJSON(fromUrl: url) { (dictionary) in
            let rounds = self.parser.rounds(fromDictionary: dictionary)
            completion(rounds)
        }
    }
}
