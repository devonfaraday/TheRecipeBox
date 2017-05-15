//
//  Bug.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 5/15/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class Bug {
    
    static let theBugKey = "TheBug"
    static let email = "email"
    static let bugType = "Bug"
    
    let theBug: String
    let email: String?
    
    init(theBug: String, email: String = "") {
        self.theBug = theBug
        self.email = email
    }
    
    init?(cloudKitRecord: CKRecord) {
        guard let bug = cloudKitRecord[Bug.theBugKey] as? String,
            let email = cloudKitRecord[Bug.email] as? String else { return nil }
        self.theBug = bug
        self.email = email
    }
    
    var ckRecord: CKRecord {
        let record = CKRecord(recordType: Bug.bugType)
        record.setValue(theBug, forKey: Bug.theBugKey)
        record.setValue(email, forKey: Bug.email)
        return record
    
    }
}
