//
//  Group+CloudKit.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/16/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

extension Group {
    
    convenience init?(cloudKitRecord: CKRecord) {
        guard let groupName = cloudKitRecord[Constants.groupNameKey] as? String else { return nil }
        self.init(groupName: groupName)
        self.groupRecordID = cloudKitRecord.recordID
        self.userReferences = cloudKitRecord[Constants.userReferencesKey] as? [CKReference]
        self.recipeReferences = cloudKitRecord[Constants.recipeReferencesKey] as? [CKReference]
        self.groupOwnerRef = cloudKitRecord[Constants.groupOwnerRefKey] as? CKReference
    }
    
    var cloudKitRecord: CKRecord {
        
        let record = CKRecord(recordType: Constants.groupRecordType)
        record[Constants.groupNameKey] = groupName as CKRecordValue
        record[Constants.userReferencesKey] = userReferences as CKRecordValue?
        record[Constants.recipeReferencesKey] = recipeReferences as CKRecordValue?
        record[Constants.groupOwnerRefKey] = groupOwnerRef as CKRecordValue?
        return record
    }
}
