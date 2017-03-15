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

class Recipe {
    
    var name: String
    var prepTime: String
    var servingSize: String
    var cookTime: String
    var recipeImageData: Data?
    var ingredients: [Ingredient]
    var instructions: [Instruction]
    var recordID: CKRecordID?
    
    var recipeImage: UIImage {
        guard let recipeImageData = recipeImageData,
            let image = UIImage(data: recipeImageData) else { return UIImage() }
        return image
    }
    
    init(name: String, prepTime: String, servingSize: String, cookTime: String, recipeImageData: Data?, ingredients: [Ingredient] = [], instructions: [Instruction] = []) {
        self.name = name
        self.prepTime = prepTime
        self.servingSize = servingSize
        self.cookTime = cookTime
        self.recipeImageData = recipeImageData
        self.ingredients = ingredients
        self.instructions = instructions
    }

    init?(cloudKitRecord: CKRecord) {
        guard let name = cloudKitRecord[Constants.recipeNameKey] as? String,
            let prepTime = cloudKitRecord[Constants.prepTimeKey] as? String,
            let servingSize = cloudKitRecord[Constants.servingSizeKey] as? String,
            let cookTime = cloudKitRecord[Constants.cookTimeKey] as? String
        
            else { return nil }
        let recipeImageData = cloudKitRecord[Constants.recipeImageKey] as? Data
//        self.init(name: name, prepTime: prepTime, servings: servings, cookTime: cookTime, recipeImageData: recipeImageData)
        self.name = name
        self.prepTime = prepTime
        self.servingSize = servingSize
        self.cookTime = cookTime
        self.recipeImageData = recipeImageData
        self.ingredients = []
        self.instructions = []
        self.recordID = cloudKitRecord.recordID
    }

}
