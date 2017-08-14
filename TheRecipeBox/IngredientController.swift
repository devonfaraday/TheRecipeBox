//
//  IngredientController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 8/14/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class IngredientController {
    
    static let shared = IngredientController()
    
    func addIngredient(ingredients: [Ingredient], toRecipe recipe: Recipe, completion: @escaping() -> Void) {
        
        // get the recipe recordID
        guard let recipeID = recipe.recordID else { return }
        let recipeReference = CKReference(recordID: recipeID, action: .deleteSelf)
        // save instuctions with recipeID as it's parent
        for ingredient in ingredients {
            ingredient.recipeReference = recipeReference
            CloudKitManager.shared.publicDatabase.save(CKRecord(ingredient: ingredient), completionHandler: { (_, error) in
                if let error = error  {
                    NSLog("Error saving ingredient \(ingredient.nameAndAmount) to recipe \(recipe.name):\n\(error.localizedDescription)")
                    
                }
                
                completion()
            })
        }
    }
    
    //TODO: delete ingredient for editing
}
