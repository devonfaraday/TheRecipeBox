//
//  Recipe+CloudKit.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/13/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit


//extension Recipe {
//
//    convenience init?(cloudKitRecord: CKRecord) {
//        guard let name = cloudKitRecord[Constants.recipeNameKey] as? String,
//            let prepTime = cloudKitRecord[Constants.prepTimeKey] as? String,
//            let servings = cloudKitRecord[Constants.servingSizeKey] as? String,
//            let cookTime = cloudKitRecord[Constants.cookTimeKey] as? String,
//            let recipeImageData = cloudKitRecord[Constants.recipeImageKey] as? Data
//        else { return nil }
//        self.init(name: name, prepTime: prepTime, servings: servings, cookTime: cookTime, recipeImageData: recipeImageData)
//            self.ingredients = []
//            self.instructions = []
//            self.recordID = cloudKitRecord.recordID
//        
//    }
// }

extension CKRecord {
    
    convenience init(recipe: Recipe) {
        self.init(recordType: "Recipe")
        self.setValue(recipe.name, forKey: Constants.recipeNameKey)
        self.setValue(recipe.prepTime, forKey: Constants.prepTimeKey)
        self.setValue(recipe.servingSize, forKey: Constants.servingSizeKey)
        self.setValue(recipe.cookTime, forKey: Constants.cookTimeKey)
        self.setValue(recipe.recipeImageData, forKey: Constants.recipeImageKey)
    }
}
