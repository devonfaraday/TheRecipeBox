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

extension Recipe {
    
    convenience init?(cloudKitRecord: CKRecord) {
        guard let name = cloudKitRecord[Constants.recipeNameKey] as? String,
            let prepTime = cloudKitRecord[Constants.prepTimeKey] as? String,
            let servingSize = cloudKitRecord[Constants.servingSizeKey] as? String,
            let cookTime = cloudKitRecord[Constants.cookTimeKey] as? String,
            let photoAsset = cloudKitRecord[Constants.recipeImageKey] as? CKAsset,
            let creationDate = cloudKitRecord.creationDate
            else { return nil }
        
        let recipeImageData = try? Data(contentsOf: photoAsset.fileURL)
        self.init(name: name, prepTime: prepTime, servingSize: servingSize, cookTime: cookTime, recipeImageData: recipeImageData, creationDate: creationDate)
        self.recipeImageData = recipeImageData
        
        self.ingredients = []
        self.instructions = []
        self.recordID = cloudKitRecord.recordID
        self.userReference = cloudKitRecord[Constants.userReferenceKey] as? CKReference
        
    }
    
    fileprivate var temporaryPhotoURL: URL {
        
        let tempDir = NSTemporaryDirectory()
        let tempURL = URL(fileURLWithPath: tempDir)
        let fileURL = tempURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
        
        try? recipeImageData?.write(to: fileURL, options: [.atomic])
        
        return fileURL
    }
    
    
}

extension CKRecord {
    
    convenience init(recipe: Recipe) {
        let recordID = recipe.recordID ?? CKRecordID(recordName: UUID().uuidString)
        self.init(recordType: Constants.recipeRecordType, recordID: recordID)
        self.setValue(recipe.name, forKey: Constants.recipeNameKey)
        self.setValue(recipe.prepTime, forKey: Constants.prepTimeKey)
        self.setValue(recipe.servingSize, forKey: Constants.servingSizeKey)
        self.setValue(recipe.cookTime, forKey: Constants.cookTimeKey)
        self.setValue(recipe.userReference, forKey: Constants.userReferenceKey)
        self[Constants.recipeImageKey] = CKAsset(fileURL: recipe.temporaryPhotoURL)
        if let creationDate = creationDate {
            recipe.creationDate = creationDate
        }
        
    }
}
    
func ==(lhs: Recipe, rhs: Recipe) -> Bool {
    return lhs.recordID?.recordName == rhs.recordID?.recordName
}

