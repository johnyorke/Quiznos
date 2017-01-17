//
//  Difficulty.swift
//  Quiznos
//
//  Created by John Yorke on 17/01/2017.
//  Copyright © 2017 John Yorke. All rights reserved.
//

import Foundation

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
