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
        self.groupName = groupName
        self.recipes = []
        self.users = []
        self.groupRecordID = cloudKitRecord.recordID
    }
}
