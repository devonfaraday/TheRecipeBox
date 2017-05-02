//
//  CloudKitManager.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/13/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitManager {
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    func fetchCurrentUser(completion: @escaping (User?) -> Void) {
        // Fetch default Apple 'Users' recordID
        
        CKContainer.default().fetchUserRecordID { (appleUserRecordID, error) in
            DispatchQueue.main.async {
                if let error = error { print(error.localizedDescription) }
                
                guard let appleUserRecordID = appleUserRecordID else { return }
                
                // Initialize a CKReference with that recordID so that we can fetch OUR real User record
                
                let appleUserReference = CKReference(recordID: appleUserRecordID, action: .deleteSelf)
                
                // Create a predicate with that reference that will go through all of the Users and FILTER through them and return us the one that has the matching reference.
                
                let predicate = NSPredicate(format: "appleUserRef == %@", appleUserReference)
                
                // Fetch the real User record
                let query = CKQuery(recordType: Constants.userRecordType, predicate: predicate)
                self.publicDatabase.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
                    if let error = error { print(error.localizedDescription) }
                    
                    guard let records = records else { return }
                    let users = records.flatMap { User(cloudKitRecord: $0 ) }
                    let user = users.first
                    completion(user)
                    
                })
            }
        }
    }
    
    func fetchRecordsWithType(_ type: String,
                              predicate: NSPredicate = NSPredicate(value: true),
                              recordFetchedBlock: ((_ record: CKRecord) -> Void)?,
                              completion: ((_ records: [CKRecord]?, _ error: Error?) -> Void)?) {
        
        var fetchedRecords: [CKRecord] = []
        
        let query = CKQuery(recordType: type, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        let perRecordBlock = { (fetchedRecord: CKRecord) -> Void in
            fetchedRecords.append(fetchedRecord)
            recordFetchedBlock?(fetchedRecord)
        }
        queryOperation.recordFetchedBlock = perRecordBlock
        
        var queryCompletionBlock: (CKQueryCursor?, Error?) -> Void = { (_, _) in }
        
        queryCompletionBlock = { (queryCursor: CKQueryCursor?, error: Error?) -> Void in
            
            if let queryCursor = queryCursor {
                // there are more results, go fetch them
                
                let continuedQueryOperation = CKQueryOperation(cursor: queryCursor)
                continuedQueryOperation.recordFetchedBlock = perRecordBlock
                continuedQueryOperation.queryCompletionBlock = queryCompletionBlock
                
                self.publicDatabase.add(continuedQueryOperation)
                
            } else {
                completion?(fetchedRecords, error)
            }
        }
        queryOperation.queryCompletionBlock = queryCompletionBlock
        
        self.publicDatabase.add(queryOperation)
    }
}

