//
//  Ingredient.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/13/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class Ingredient {
    var nameAndAmount: String
    var recipeReference: CKReference?
    
    init(nameAndAmount: String) {
        self.nameAndAmount = nameAndAmount
    }
}
