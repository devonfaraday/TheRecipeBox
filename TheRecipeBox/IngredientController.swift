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
    
    func modify(ingredients: [Ingredient], completion: @escaping() -> Void) {
        let cloudKitManager = CloudKitManager()
        let records = ingredients.flatMap { CKRecord(ingredient: $0)}
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        cloudKitManager.publicDatabase.add(operation)
        completion()
    }
    
    func delete(ingredient: Ingredient, completion: @escaping() -> Void) {
        guard let recordID = ingredient.recordID else { return }
        
        CloudKitManager.shared.publicDatabase.delete(withRecordID: recordID) { (_, error) in
            if let error = error {
                NSLog("Could not delete instruction \(ingredient.nameAndAmount):\n\(error.localizedDescription)")
            }
            completion()
        }
    }
    
}
