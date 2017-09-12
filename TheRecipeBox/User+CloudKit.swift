//
//  User+CloudKit.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/15/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

extension User {
 
     convenience init?(cloudKitRecord: CKRecord) {
        guard let username = cloudKitRecord[Constants.userusernameKey] as? String,
        let photoAsset = cloudKitRecord[Constants.profileImageKey] as? CKAsset,
        let appleUserRef = cloudKitRecord[Constants.defaultUserReferenceKey] as? CKReference else { return nil }
        
        let imageData = try? Data(contentsOf: photoAsset.fileURL)
        self.init(username: username, profilePhotoData: imageData, appleUserRef: appleUserRef)
        self.recipes = []
        self.userRecordID = cloudKitRecord.recordID
    }
    
    fileprivate var temporaryPhotoURL: URL {
        
        let tempDir = NSTemporaryDirectory()
        let tempURL = URL(fileURLWithPath: tempDir)
        let fileURL = tempURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
        
        try? profilePhotoData?.write(to: fileURL, options: [.atomic])
        
        return fileURL
    }
    
    var cloudKitRecord: CKRecord {
        let record = CKRecord(recordType: Constants.userRecordType)
//        let recordID = userRecordID ?? CKRecordID(recordName: UUID().uuidString)
//        let record = CKRecord(recordType: Constants.userRecordType, recordID: recordID)
        record[Constants.defaultUserReferenceKey] = appleUserRef as CKRecordValue
        record[Constants.userusernameKey] = username as CKRecordValue
        record[Constants.profileImageKey] = CKAsset(fileURL: temporaryPhotoURL)
        
        return record
    }
}


/*
 
 convenience init(recipe: Recipe) {
 self.init(recordType: Constants.recipeRecordType)
 self.setValue(recipe.name, forKey: Constants.recipeNameKey)
 self.setValue(recipe.prepTime, forKey: Constants.prepTimeKey)
 self.setValue(recipe.servingSize, forKey: Constants.servingSizeKey)
 self.setValue(recipe.cookTime, forKey: Constants.cookTimeKey)
 self[Constants.recipeImageKey] = CKAsset(fileURL: recipe.temporaryPhotoURL)
 

 
 */
