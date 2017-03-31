//
//  Group.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/16/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class Group: Equatable {
    
    var groupName: String
    var groupRecordID: CKRecordID?
    var userReferences: [CKReference]?
    var recipeReferences: [CKReference]?
    
    init(groupName: String) {
        self.groupName = groupName
        self.recipeReferences = []
        self.userReferences = []
    }
}

func ==(lhs: Group, rhs: Group) -> Bool {
    return lhs === rhs
}
