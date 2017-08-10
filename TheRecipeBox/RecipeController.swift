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
    
//    var currentUser: User?
    var recipeOwnerProfileImage: UIImage?
    var allGroupsRecipes = [Recipe]()
    var currentRecipes = [Recipe]()
    
    // MARK: - Recipe Functions
    
    // Creating the recipe with ingredients
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
    
    // add recipe to cloud kit with instructions and ingredients in a parent to child relationship
    func addRecipeToCloudKit(recipe: Recipe, ingredients: [Ingredient], instructions: [Instruction], completion: @escaping ((Error?) -> Void) = { _ in }) {
        
        
        
        guard let image = recipe.recipeImage,
            let data = UIImageJPEGRepresentation(image, 1.0),
            let currentUser = UserController.shared.currentUser
            else { return }
        guard let userID = currentUser.userRecordID else { return }
        
        let newRecipe = recipe
        newRecipe.ingredients = ingredients
        newRecipe.instructions = instructions
        newRecipe.recipeImageData = data
        newRecipe.userReference = CKReference(recordID: userID, action: .deleteSelf)
        RecipeController.shared.currentRecipes.insert(newRecipe, at: 0)
        
        let recipeRecord = CKRecord(recipe: newRecipe)
        newRecipe.recordID = recipeRecord.recordID
        
        
        Constants.publicDatabase.save(recipeRecord) { (_, error) in
            if let error = error {
                NSLog("Error: \(error)\nProblem saving to public database")
                completion(error)
                return
            } else {
                guard let recordID = newRecipe.recordID else { return }
                for ingredient in ingredients {
                    ingredient.recipeReference = CKReference(recordID: recordID, action: .deleteSelf)
                    guard let index =  ingredients.index(of: ingredient) else { return }
                    ingredient.index = index
                    let ingredientRecord = CKRecord(ingredient: ingredient)
                    Constants.publicDatabase.save(ingredientRecord, completionHandler: { (_, _) in
                        print("ingredient saved")
                    })
                }
                for instruction in instructions {
                    instruction.recipeReference = CKReference(recordID: recordID, action: .deleteSelf)
                    guard let index = instructions.index(of: instruction) else { return }
                    instruction.index = index
                    let record = CKRecord(instruction: instruction)
                    Constants.publicDatabase.save(record, completionHandler: { (_, _) in
                        print("instruction saved")
                    })
                }

                print("Saving success")
            }
        }
    }
    
    // delete recipe
    func deleteRecipeRecord(recipeID: CKRecordID, completion: @escaping ((Error?) -> Void) = { _ in }) {
        cloudKitManager.publicDatabase.delete(withRecordID: recipeID) { (_, error) in
            if let error = error {
                NSLog("Error deleting \(recipeID)\n\(error.localizedDescription)")
                completion(error)
            } else {
                completion(nil)
            }
            
        }
    }
    
    // MARK: - Fetch Functions
    
    func fetchIngredientsFor(recipe: Recipe, completion: @escaping([Ingredient]) -> Void) {
        guard let recipeRecordID = recipe.recordID else { return }
        
        let predicate = NSPredicate(format: "recipeReference == %@", recipeRecordID)
        let query = CKQuery(recordType: Constants.ingredientRecordType, predicate: predicate)
        Constants.publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                NSLog("Error: \(error.localizedDescription)\nCould not fetch ingredients from cloudKit")
            } else {
                guard let records = records else { return }
                let unSortedIngredients = records.flatMap { Ingredient(cloudKitRecord: $0) }
                print(unSortedIngredients)
                let ingredients = unSortedIngredients.sorted(by: { $0.index < $1.index  })
                print(ingredients)
                
                
                completion(ingredients)
            }
        }
    }
    
    func fetchInstructionsFor(recipe: Recipe, completion: @escaping([Instruction]) -> Void) {
        guard let recipeRecordID = recipe.recordID else { return }
        let predicate = NSPredicate(format: "recipeReference == %@", recipeRecordID)
        let query = CKQuery(recordType: Constants.instructionsRecordType, predicate: predicate)
        Constants.publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                NSLog("Error: \(error.localizedDescription)\nCould not fetch instructions from cloudKit")
            } else {
                guard let records = records else { return }
                let unSortedInstructions = records.flatMap { Instruction(cloudKitRecord: $0) }
                let instructions = unSortedInstructions.sorted(by: { $0.index < $1.index })
                
                completion(instructions)
            }
        }
    }
    
    // Could be fine tuned to get only users from the groups the user is a part of.
    func fetchProfileImageOfRecipeOwner(recipe: Recipe, completion: @escaping(UIImage) -> Void) {
        guard let userReference = recipe.userReference else { return }
        for user in UserController.shared.allUsers {
            guard let userID = user.userRecordID else { return }
            if userID == userReference.recordID  {
                self.recipeOwnerProfileImage = user.profilePhoto
                completion(user.profilePhoto)
            }
        }
    }
    
    func fetchAllRecipes(completion: @escaping([Recipe]) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Constants.recipeRecordType, predicate: predicate)
        Constants.publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                NSLog("Error fetching all recipes:\n\(error.localizedDescription)")
                completion([])
                return
            } else {
                guard let records = records else { completion([]); return }
                let recipes = records.flatMap { Recipe(cloudKitRecord: $0) }
                completion(recipes)
            }
        }
    }
    
    func modify(recipe: Recipe, completion: @escaping() -> Void) {
        let record = CKRecord(recipe: recipe)
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        self.cloudKitManager.publicDatabase.add(operation)
        completion()
    }
    
    
    // MARK: - Temp Func to resize photos
    
    func fecthAndResizePhotos(completion: @escaping() -> Void) {
        fetchAllRecipes { (recipes) in
            for recipe in recipes {
                NSLog("\(String(describing: recipe.recipeImage?.cgImage?.width))")
                guard let image = recipe.recipeImage
                    else { completion(); return }
                let newImage = ImageResizer.resizeImage(image: image, targetSize: CGSize(width: 828, height: 400))
                recipe.recipeImageData = UIImageJPEGRepresentation(newImage, 1.0)
                self.modify(recipe: recipe, completion: { 
                    NSLog("Recipe image updated")
                    NSLog("\(String(describing: recipe.recipeImage?.cgImage?.width))")
                })
            }
            completion()
        }
    }
}
