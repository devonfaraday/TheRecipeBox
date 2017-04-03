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
    
    init(instruction: String) {
        self.instruction = instruction
    }
}

func ==(lhs: Instruction, rhs: Instruction) -> Bool {
    return lhs === rhs
}
