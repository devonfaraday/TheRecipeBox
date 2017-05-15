//
//  BugController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 5/15/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class BugController {
    
    static let shared = BugController()
    
    func createbugWith(bug: String, andEmail email: String, completion: @escaping() -> Void) {
        let bug = Bug(theBug: bug, email: email)
        let record = bug.ckRecord
        
        CloudKitManager.shared.publicDatabase.save(record) { (_, error) in
            if let error = error {
                NSLog("Error saving bug request:\n\(error.localizedDescription)")
            }
            completion()
            
        }
    }
    
    func createbugWith(bug: String, completion: @escaping() -> Void) {
        let bug = Bug(theBug: bug)
        let record = bug.ckRecord
        
        CloudKitManager.shared.publicDatabase.save(record) { (_, error) in
            if let error = error {
                NSLog("Error saving bug request:\n\(error.localizedDescription)")
            }
            completion()
            
        }
    }

}
