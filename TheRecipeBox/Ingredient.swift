//
//  Ingredient.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/13/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class Ingredient: Equatable {
    var nameAndAmount: String
    var recipeReference: CKReference?
    var index: Int
    var recordID: CKRecordID?
    
    init(nameAndAmount: String, index: Int = 0) {
        self.nameAndAmount = nameAndAmount
        self.index = index
    }
}

extension Ingredient {
    
    convenience init?(cloudKitRecord: CKRecord) {
        guard let name = cloudKitRecord[Constants.ingredientKey] as? String,
            let index = cloudKitRecord["index"] as? Int else { return nil }
        self.init(nameAndAmount: name, index: index)
        self.recipeReference = cloudKitRecord[Constants.recipeReferenceKey] as? CKReference
    }
}

extension CKRecord {
    convenience init(ingredient: Ingredient) {
        let recordID = ingredient.recordID ?? CKRecordID(recordName: UUID().uuidString)
        self.init(recordType: Constants.ingredientRecordType, recordID: recordID)
        self.setValue(ingredient.nameAndAmount, forKey: Constants.ingredientKey)
        self.setValue(ingredient.recipeReference, forKey: Constants.recipeReferenceKey)
        self.setValue(ingredient.index, forKey: "index")
    }
}


func ==(lhs: Ingredient, rhs: Ingredient) -> Bool {
    return lhs === rhs
}
