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
    
    
    func fetchUsername(for recordID: CKRecordID,
                       completion: @escaping ((_ givenName: String?, _ familyName: String?) -> Void) = { _,_ in }) {
        
        let recordInfo = CKUserIdentityLookupInfo(userRecordID: recordID)
        let operation = CKDiscoverUserIdentitiesOperation(userIdentityLookupInfos: [recordInfo])
        
        var userIdenties = [CKUserIdentity]()
        operation.userIdentityDiscoveredBlock = { (userIdentity, _) in
            userIdenties.append(userIdentity)
        }
        operation.discoverUserIdentitiesCompletionBlock = { (error) in
            if let error = error {
                NSLog("Error getting username from record ID: \(error)")
                completion(nil, nil)
                return
            }
            
            let nameComponents = userIdenties.first?.nameComponents
            completion(nameComponents?.givenName, nameComponents?.familyName)
        }
        
        CKContainer.default().add(operation)
    }
    
    
    
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
}

