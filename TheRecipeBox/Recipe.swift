//
//  Recipe.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/13/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class Recipe: Equatable {
    
    var name: String
    var prepTime: String
    var servingSize: String
    var cookTime: String
    var recipeImageData: Data?
    var ingredients: [Ingredient]
    var instructions: [Instruction]
    var recordID: CKRecordID?
    var userReference: CKReference?
    var creationDate: Date
    
    var recipeImage: UIImage? {
        guard let data = recipeImageData,
            let image = UIImage(data: data) else { return UIImage() }
        return image
    }
    
    init(name: String, prepTime: String, servingSize: String, cookTime: String, recipeImageData: Data?, ingredients: [Ingredient] = [], instructions: [Instruction] = [], creationDate: Date = Date()) {
        self.name = name
        self.prepTime = prepTime
        self.servingSize = servingSize
        self.cookTime = cookTime
        self.recipeImageData = recipeImageData
        self.ingredients = ingredients
        self.instructions = instructions
        self.creationDate = creationDate
        
    }

    
}
    
func ==(lhs: Recipe, rhs: Recipe) -> Bool {
    return lhs.ingredients == rhs.ingredients
}

