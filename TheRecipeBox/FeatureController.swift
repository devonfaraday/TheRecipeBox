//
//  FeatureController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 5/15/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class FeatureController {
    
    static let shared = FeatureController()
    
    func createFeatureWith(feature: String, andEmail email: String, completion: @escaping() -> Void) {
        let feature = Feature(thefeature: feature, email: email)
        let record = feature.ckRecord
        
        CloudKitManager.shared.publicDatabase.save(record) { (_, error) in
            if let error = error {
                NSLog("Error saving feature request:\n\(error.localizedDescription)")
            }
            completion()
            
        }
    }
    
    func createFeatureWith(feature: String, completion: @escaping() -> Void) {
        let feature = Feature(thefeature: feature)
        let record = feature.ckRecord
        
        CloudKitManager.shared.publicDatabase.save(record) { (_, error) in
            if let error = error {
                NSLog("Error saving feature request:\n\(error.localizedDescription)")
            }
            completion()
            
        }
    }
}
