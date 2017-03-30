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
    
    // MARK: - CloudKit Types
    
    static let recipeRecordType = "Recipe"
    static let ingredientRecordType = "Ingredient"
    static let instructionsRecordType = "Instructions"
    static let userRecordType = "User"
    static let groupRecordType = "Group"
    
    // MARK: - CloudKit Keys
    
    static let recipeNameKey = "name"
    static let prepTimeKey = "prepTime"
    static let servingSizeKey = "servingSize"
    static let cookTimeKey = "cookTime"
    static let recipeImageKey = "recipeImage"
    static let recipeReferenceKey = "recipeReference"
    static let ingredientKey = "ingredient"
    static let instructionKey = "instruction"
    static let profileImageKey = "profileImage"
    static let userusernameKey = "username"
    static let groupNameKey = "groupName"
    static let userReferenceKey = "userReference"
    static let userReferencesKey = "userReferences"
    static let recipeReferencesKey = "recipeReferences"
    static let defaultUserReferenceKey = "appleUserRef"
    
    // MARK: - Segues
    
    static let toAddRecipeSegue = "toAddRecipe"
    static let toShowRecipeSegue = "toShowRecipe"
    static let toUserCreationSegue = "toUserCreation"
    static let toProfileSegue = "toProfile"
    static let toRecipeList = "toRecipeList"
    static let toAddRecipeToGroupSegue = "toAddRecipeToGroup"
    
    // MARK: - Notification Names
    
    static let recipesDidChangeNotificationName = Notification.Name("recipesDidChange")
    
     // MARK: - Cloud Kit Databases
    
    static let publicDatabase = CKContainer.default().publicCloudDatabase
    static let privateDatabase = CKContainer.default().privateCloudDatabase
    
    // MARK: - Reuse Identifiers
    static let profileFeedIdentifier = "profileFeedCell"
    static let addRecipeCellIdentifier = "addRecipeCell"
    static let recipeCellIdentifier = "recipeCell"
    static let groupCellIdentifier = "groupCell"
    static let userCellIdentifier = "userCell"
    
}
