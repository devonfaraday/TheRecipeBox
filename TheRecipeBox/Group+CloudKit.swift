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
}

extension CKRecord {
    
    convenience init(group: Group) {
        let recordID = group.groupRecordID ?? CKRecordID(recordName: UUID().uuidString)
        self.init(recordType: Constants.groupRecordType, recordID: recordID)
        self.setValue(group.groupName, forKey: Constants.groupNameKey)
        self.setValue(group.groupOwnerRef, forKey: Constants.groupOwnerRefKey)
        self.setValue(group.recipeReferences, forKey: Constants.recipeReferencesKey)
        self.setValue(group.userReferences, forKey: Constants.userReferencesKey)
        group.groupRecordID = recordID
    }
}
