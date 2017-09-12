//
//  Instructions.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/13/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class Instruction: Equatable {
    var instruction: String
    var recipeReference: CKReference?
    var index: Int
    
    init(instruction: String, index: Int = 0) {
        self.instruction = instruction
        self.index = index
    }
}

func ==(lhs: Instruction, rhs: Instruction) -> Bool {
    return lhs === rhs
}
