//
//  GroupController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/17/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class GroupController {
    
    static let shared = GroupController()
    let publicDB = CKContainer.default().publicCloudDatabase
    
    var groups = [Group]()
    
    func fetchAllGroups(completion: @escaping() -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Group", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("an error accured \(error)")
                completion()
                return
            } else {
                guard let records = records else { return }
                let groups = records.flatMap { Group(cloudKitRecord: $0) }
                self.groups = groups
                completion()
                
            }
        }
    }
    
    func createGroupWith(name: String) -> Group {
        return Group(groupName: name)
        
    }
    
    
    func saveToCloudKit(group: Group, completion: @escaping((Error?) -> Void) = { _ in })  {
        
        let record = group.cloudKitRecord
        group.groupRecordID = record.recordID
        
        
        publicDB.save(record) { (_, error) in
            if let error = error {
                print("Error here")
                completion(error)
                
            }
            self.groups.append(group)
        }
    }
    
    func fetchUsersIn(group: Group, completion: @escaping([User]) -> Void = { _ in }) {
        var userRecordIDs = [CKRecordID]()
        var users = [User]()
        guard let usersReferences = group.userReferences else { return }
        for user in usersReferences {
            let userID = user.recordID
            userRecordIDs.append(userID)
            
        }
        let group = DispatchGroup()
        for id in userRecordIDs {
            group.enter()
            publicDB.fetch(withRecordID: id, completionHandler: { (record, _) in
                guard let record = record else { return }
                guard let user = User(cloudKitRecord: record) else { return }
                users.append(user)
                group.leave()
            })
        }
        group.notify(queue: DispatchQueue.main) {
            completion(users)
        }
    }    
}
