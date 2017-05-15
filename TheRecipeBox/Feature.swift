//
//  Feature.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 5/15/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class Feature {
    
    static let thefeatureKey = "TheFeature"
    static let email = "email"
    static let featureType = "Feature"
    
    let thefeature: String
    let email: String?
    
    init(thefeature: String, email: String = "") {
        self.thefeature = thefeature
        self.email = email
    }
    
    init?(cloudKitRecord: CKRecord) {
        guard let feature = cloudKitRecord[Feature.thefeatureKey] as? String,
            let email = cloudKitRecord[Feature.email] as? String else { return nil }
        self.thefeature = feature
        self.email = email
    }
    
    var ckRecord: CKRecord {
        let record = CKRecord(recordType: Feature.featureType)
        record.setValue(thefeature, forKey: Feature.thefeatureKey)
        record.setValue(email, forKey: Feature.email)
        return record
        
}
}
