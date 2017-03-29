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
    
    private let CreatorUserRecordIDKey = "creatorUserRecordID"
    private let LastModifiedUserRecordIDKey = "creatorUserRecordID"
    private let CreationDateKey = "creationDate"
    private let ModificationDateKey = "modificationDate"
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    func fetchRecords(ofType type: String,
                      withSortDescriptors sortDescriptors: [NSSortDescriptor]? = nil,
                      completion: @escaping ([CKRecord]?, Error?) -> Void) {
        let query = CKQuery(recordType: type, predicate: NSPredicate(value: true))
        query.sortDescriptors = sortDescriptors
        publicDatabase.perform(query, inZoneWith: nil, completionHandler: completion)
    }
    
    func save(_ record: CKRecord, completion: @escaping ((Error?) -> Void) = { _ in }) {
        publicDatabase.save(record) { (_, error) in
            completion(error)
        }
    }
    
    
//    func fetchUsername(for recordID: CKRecordID,
//                       completion: @escaping ((_ givenName: String?,_ familyName: String?) -> Void) = { _,_ in }) {
//        
//        let recordInfo = CKUserIdentityLookupInfo(userRecordID: recordID)
//        let operation = CKDiscoverUserIdentitiesOperation(userIdentityLookupInfos: [recordInfo])
//        
//        var userIdenties = [CKUserIdentity]()
//        
//        
//        operation.userIdentityDiscoveredBlock = { (userIdentity, _) in
//            userIdenties.append(userIdentity)
//        }
//        operation.discoverUserIdentitiesCompletionBlock = { (error) in
//            if let error = error {
//                NSLog("Error getting username from record ID: \(error)")
//                completion(nil, nil)
//                return
//            }
//            
//            let nameComponents = userIdenties.first?.nameComponents
//            completion(nameComponents?.givenName, nameComponents?.familyName)
//        }
//        
//        CKContainer.default().add(operation)
//    }
    
    
    
    func subscribeToCreationOfRecords(withType type: String, completion: @escaping ((Error?) -> Void) = { _ in }) {
        let subscription = CKQuerySubscription(recordType: type, predicate: NSPredicate(value: true), options: .firesOnRecordCreation)
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = "Theres a new message post on the bulletin board!"
        subscription.notificationInfo = notificationInfo
        publicDatabase.save(subscription) { (_, error) in
            if let error = error {
                NSLog("Error saving subscription:\n\(error)")
            }
            completion(error)
        }
    }
    
    
    func fetchRecord(withID recordID: CKRecordID, completion: ((_ record: CKRecord?, _ error: Error?) -> Void)?) {
        
        publicDatabase.fetch(withRecordID: recordID) { (record, error) in
            
            completion?(record, error)
        }
    }
    
    
    func fetchLoggedInUserRecord(_ completion: ((_ record: CKRecord?, _ error: Error? ) -> Void)?) {
        
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            
            if let error = error,
                let completion = completion {
                completion(nil, error)
            }
            
            if let recordID = recordID,
                let completion = completion {
                
                self.fetchRecord(withID: recordID, completion: completion)
                
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
    
    
    func fetchCurrentUserRecords(_ type: String, completion: ((_ records: [CKRecord]?, _ error: Error?) -> Void)?) {
        
        fetchLoggedInUserRecord { (record, error) in
            
            if let record = record {
                
                let predicate = NSPredicate(format: "%K == %@", argumentArray: [self.CreatorUserRecordIDKey, record.recordID])
                
                self.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: nil, completion: completion)
            }
        }
    }
    
    
    func fetchCurrentUser(completion: @escaping (User?) -> Void) {
        // Fetch default Apple 'Users' recordID
        
        CKContainer.default().fetchUserRecordID { (appleUserRecordID, error) in
            
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

