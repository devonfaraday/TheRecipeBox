//
//  RecipeController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/13/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

class RecipeController {
    
    // MARK: - Properties
    
    static let shared = RecipeController()
    private let cloudKitManager = CloudKitManager()
    var recipes = [Recipe]() {
        didSet {
            NotificationCenter.default.post(name: Constants.recipesDidChangeNotificationName, object: self)
        }
    }
    
    // MARK: - Recipe Functions
    
    func createRecipeWith(name: String, prepTime: String, servings: String, cookTime: String, recipeImageData: Data?) -> Recipe {
        return Recipe(name: name, prepTime: prepTime, servingSize: servings, cookTime: cookTime, recipeImageData: recipeImageData)
    }
    
    func createIngredientWith(nameAndAmount: String) -> Ingredient {
        return Ingredient(nameAndAmount: nameAndAmount)
    }
    
    func createInstructionWith(instruction: String) -> Instruction {
        let newInstruction = Instruction(instruction: instruction)
       
        return newInstruction
    }
    
    func addRecipeToCloudKit(recipe: Recipe, ingredients: [Ingredient], instructions: [Instruction], completion: @escaping ((Error?) -> Void) = { _ in }) {
        
        let newRecipe = recipe
        newRecipe.ingredients = ingredients
        newRecipe.instructions = instructions
        
        let recipeRecord = CKRecord(recipe: newRecipe)
        newRecipe.recordID = recipeRecord.recordID
        
        Constants.publicDatabase.save(recipeRecord) { (_, error) in
            if let error = error {
                NSLog("Error: \(error.localizedDescription)\nProblem saving to public database")
                completion(error)
                return
            } else {
                guard let recipeRecordID = newRecipe.recordID else { return }
                for ingredient in newRecipe.ingredients {
                    
                    ingredient.recipeReference = CKReference(recordID: recipeRecordID, action: .deleteSelf)
                }
                for instruction in newRecipe.instructions {
                    instruction.recipeReference = CKReference(recordID: recipeRecordID, action: .deleteSelf)
                }
                
                let ingredientRecords = newRecipe.ingredients.flatMap { CKRecord(ingredient:  $0) }
                let instructionRecords = newRecipe.instructions.flatMap { CKRecord(instruction:  $0) }
                let ingredientsAndInstructions = [ingredientRecords, instructionRecords]
                let objectsForModifing = ingredientsAndInstructions.flatMap { $0 }
                
                var modifyOperation = CKModifyRecordsOperation()
                modifyOperation = CKModifyRecordsOperation(recordsToSave: objectsForModifing, recordIDsToDelete: nil)
                
                modifyOperation.completionBlock = {
                    self.recipes.append(newRecipe)
                    completion(nil)
                }
                
                modifyOperation.savePolicy = .changedKeys
                Constants.publicDatabase.add(modifyOperation)
                print("Saving success")
            }
            
            
        }
        
    }
    
    func fetchAllRecipes(completion: @escaping() -> Void) {
//        let predicate = NSPredicate(value: true)
//        let query = CKQuery(recordType: Constants.recipeRecordType, predicate: predicate)
//        Constants.publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
//            if let error = error {
//                NSLog("Error: \(error.localizedDescription)\nCould not fetch recipe from cloudKit")
//            } else {
//                guard let records = records else { return }
//                var recipes = records.flatMap { Recipe(cloudKitRecord: $0) }
//                self.recipes = recipes
//                completion()
//            }
//        }
        cloudKitManager.fetchRecords(ofType: Constants.recipeRecordType) { (records, error) in
            defer { completion() }
            if let error = error {
                print("error \(error.localizedDescription)")
            }
            guard let records = records else { return }
            self.recipes = records.flatMap { Recipe(cloudKitRecord: $0) }
            completion()
        }

    }
    
    func fetchIngredientsFor(recipe: Recipe, completion: @escaping() -> Void) {
        guard let recipeRecordID = recipe.recordID else { return }
        
        let predicate = NSPredicate(format: "recipeReference == %@", recipeRecordID)
        let query = CKQuery(recordType: Constants.ingredientRecordType, predicate: predicate)
        Constants.publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                NSLog("Error: \(error.localizedDescription)\nCould not fetch ingredients from cloudKit")
            } else {
                guard let records = records else { return }
                let ingredients = records.flatMap { Ingredient(cloudKitRecord: $0) }
                recipe.ingredients = ingredients
                completion()
            }
        }
    }
    
    func fetchInstructionsFor(recipe: Recipe, completion: @escaping() -> Void) {
        guard let recipeRecordID = recipe.recordID else { return }
        let predicate = NSPredicate(format: "recipeReference == %@", recipeRecordID)
        let query = CKQuery(recordType: Constants.instructionsRecordType, predicate: predicate)
        Constants.publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                NSLog("Error: \(error.localizedDescription)\nCould not fetch instructions from cloudKit")
            } else {
                guard let records = records else { return }
                let instructions = records.flatMap { Instruction(cloudKitRecord: $0) }
                recipe.instructions = instructions
                completion()
            }
        }

    }
    
}
