//
//  UserController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/17/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

class UserController {
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    let currentUserWasSetNotification = Notification.Name("currentUserWasSet")
    static let shared = UserController()
    
    var appleUserRecordID: CKRecordID?
    let CKManager = CloudKitManager()
    var currentUser: User?
    
    var currentRecipes: [Recipe] = []
    var userGroups = [Group]()
    
    init() {
    CKContainer.default().fetchUserRecordID { (recordID, _) in
        guard let recordID = recordID else { return }
        self.appleUserRecordID = recordID
        
        }
        
        self.CKManager.fetchCurrentUser { (user) in
            guard let user = user else {  return  }
            
            self.currentUser = user
            
            UserController.shared.fetchRecipesForCurrent(user: user, completion: { (recipes) in
                
                self.currentRecipes = recipes
            })
            
            GroupController.shared.fetchGroupsForCurrent(user: user) {
                self.userGroups = GroupController.shared.userGroups
            }
        }
        
        
        
        
    }
    func fetchRecipesForCurrent(user: User, completion: @escaping([Recipe]) -> Void) {
        
        guard let userID = user.userRecordID else { return }
        let predicate = NSPredicate(format: "userReference == %@", userID)
        let query = CKQuery(recordType: Constants.recipeRecordType, predicate: predicate)
        CKManager.publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print(error.localizedDescription)
                completion([])
                return
            } else {
                guard let records = records else { return }
                let recipes = records.flatMap { Recipe(cloudKitRecord: $0) }
                self.currentUser?.recipes = recipes
                completion(recipes)
            }
            
        }
    }
    
    
    
    func addUserToGroupRecord(user: User, group: Group, completion: @escaping(Error?) -> Void = { _ in }) {
        
        guard let userID = user.userRecordID,
            let groupID = group.groupRecordID  else { return }
        publicDatabase.fetch(withRecordID: groupID) { (record, error) in
            if let error = error {
                print("\(error)")
                completion(error)
            } else if let record = record {
                let reference = CKReference(recordID: userID, action: .none)
                guard let userReferences = group.userReferences else { return }
                
                if !userReferences.contains(reference) {
                    group.userReferences?.append(reference)
                } 
                
                record.setValue(group.userReferences, forKey: "userReferences")
                self.publicDatabase.save(record, completionHandler: { (record, error) in
                    if let error = error {
                        print("\(error)")
                        completion(error)
                    }
                    if let record = record,
                        let group = Group(cloudKitRecord: record),
                        let refs = group.userReferences {
                        NSLog(group.groupName)
                        for ref in refs {
                            NSLog("\(ref)")
                        }
                    }
                    print("saving succeeded")
                    completion(nil)
                })
            }
        }
    }
    
    
    func checkForUser(username: String, completion: @escaping(User) -> Void = { _ in }) {
        
        
        let predicate = NSPredicate(format: "username == %@ ", username)
        let query = CKQuery(recordType: "User", predicate: predicate)
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                NSLog("Error retrieving username\n\(error.localizedDescription)")
            } else {
                guard let records = records else { return }
                let users = records.flatMap { User(cloudKitRecord:  $0 )}
                guard let user = users.first else { return }
                
                completion(user)
            }
        }
    }
    
    
    
    func createUserWith(username: String, profilePhotoData: Data?, completion: @escaping (User?) -> Void) {
        
        guard let appleUserRecordID = appleUserRecordID else { return }
        let appleUserRef = CKReference(recordID: appleUserRecordID, action: .deleteSelf)
        
        let user = User(username: username, profilePhotoData: profilePhotoData, appleUserRef: appleUserRef)
        if user.username.contains(" ") {
            let username = user.username.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            user.username = username
        }
        let userRecord = user.cloudKitRecord
        
        publicDatabase.save(userRecord) { (record, error) in
            if let error = error {
                print("\(error.localizedDescription)")
            }
            guard let record = record, let currentUser = User(cloudKitRecord: record) else { completion(nil); return }
            
            self.currentUser = currentUser
            completion(currentUser)
        }
        
    }
}

