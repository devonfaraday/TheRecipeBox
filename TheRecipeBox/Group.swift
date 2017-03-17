//
//  Group.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/16/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class Group {
    
    var users: [User]
    var recipes: [Recipe]
    var groupName: String
    var groupRecordID: CKRecordID?
    
    init(users: [User] = [], recipes: [Recipe] = [], groupName: String) {
        self.users = users
        self.recipes = recipes
        self.groupName = groupName
    }
}
