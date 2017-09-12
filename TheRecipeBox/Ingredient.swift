//
//  Ingredient.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/13/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class Ingredient: Equatable {
    var nameAndAmount: String
    var recipeReference: CKReference?
    var index: Int
    
    init(nameAndAmount: String, index: Int = 0) {
        self.nameAndAmount = nameAndAmount
        self.index = index
    }
}

func ==(lhs: Ingredient, rhs: Ingredient) -> Bool {
    return lhs === rhs
}
