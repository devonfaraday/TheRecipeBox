//
//  Constants.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/13/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

struct Constants {
    
    // MARK: - CloudKit Keys
    
    static let recipeRecordType = "Recipe"
    static let ingredientRecordType = "Ingredient"
    static let instructionsRecordType = "Instructions"
    static let recipeNameKey = "name"
    static let prepTimeKey = "prepTime"
    static let servingSizeKey = "servingSize"
    static let cookTimeKey = "cookTime"
    static let recipeImageKey = "recipeImage"
    static let recipeReferenceKey = "recipeReference"
    static let ingredientKey = "ingredient"
    static let instructionKey = "instruction"
    static let profileImageKey = "profileImage"
    static let userFullNameKey = "fullName"
    static let groupNameKey = "groupName"
    static let userReferenseKey = "userReference"
    
    // MARK: - Segues
    
    static let toAddRecipeSegue = "toAddRecipe"
    static let toShowRecipeSegue = "toShowRecipe"
    
    // MARK: - Notification Names
    
    static let recipesDidChangeNotificationName = Notification.Name("recipesDidChange")
    
     // MARK: - Cloud Kit Databases
    
    static let publicDatabase = CKContainer.default().publicCloudDatabase
    static let privateDatabase = CKContainer.default().privateCloudDatabase
    
    // MARK: - Reuse Identifiers
    static let profileFeedIdentifier = "profileFeedCell"
    static let addRecipeCellIdentifier = "addRecipeCell"
    static let recipeCellIdentifier = "recipeCell"
    
}
