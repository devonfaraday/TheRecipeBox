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
    var allUsers = [User]()
    
    
    init() {
        // switch fetching default user record id to app delegate
   // CKContainer.default().fetchUserRecordID { (recordID, _) in
   //     guard let recordID = recordID else { return }
   //     self.appleUserRecordID = recordID
        
   //     }
        
        self.CKManager.fetchCurrentUser { (user) in
            guard let user = user else {  return  }
            
            self.currentUser = user
            
            UserController.shared.fetchRecipesForCurrent(user: user, completion: { (recipes) in
                
                RecipeController.shared.currentRecipes = recipes
            })
            
            GroupController.shared.fetchGroupsForCurrent(user: user) {

            }
            
        }
        
        fetchAllUsers { 
            print("Users Fetched")
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
                let recipes = records.flatMap { Recipe(cloudKitRecord: $0) }.sorted(by: {$0.creationDate > $1.creationDate })
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
    
    
    
    func fetchAllUsers(completion: @escaping() -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Constants.userRecordType, predicate: predicate)
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("an error accured \(error)")
                completion()
                return
            } else {
                guard let records = records else { return }
                let users = records.flatMap { User(cloudKitRecord: $0) }
                self.allUsers = users
                
                completion()
                
            }
        }
    }
    
    func fetchGroupsRecipesFor(user: User, completion: @escaping() -> Void) {
        
        var recipeRecordIDs = [CKRecordID]()
        var recipes = [Recipe]()
        
        guard let userID = user.userRecordID else { return }
        let groupPredicate = NSPredicate(format: "userReferences CONTAINS %@", userID)
        let groupQuery = CKQuery(recordType: Constants.groupRecordType, predicate: groupPredicate)
        
        publicDatabase.perform(groupQuery, inZoneWith: nil) { (records, error) in
            if let error = error {
                NSLog(error.localizedDescription)
                completion()
                return
            }
                guard let records = records else { return }
                print("Found recipes")
                let groups = records.flatMap { Group(cloudKitRecord: $0) }
                for group in groups {
                    if let recipeReferences = group.recipeReferences {
                        
                    print(group.groupName)
                    for recipe in  recipeReferences {
                        print("appending Recipe record IDs)")
                        let recordID = recipe.recordID
                        recipeRecordIDs.append(recordID)
                    }
                }
            }
                let group = DispatchGroup()
                for id in recipeRecordIDs {
                    print("Entering Group")
                    group.enter()
                    self.publicDatabase.fetch(withRecordID: id, completionHandler: { (record, _) in
                        if let record = record {
                            if let recipe = Recipe(cloudKitRecord: record) {
                        recipes.append(recipe)
                        }
                        }
                        print("Leaving group")
                        group.leave()
                    })
                }
                group.notify(queue: DispatchQueue.main, execute: {
                    var sorted = recipes.sorted(by: {$0.creationDate > $1.creationDate })
                    print("Completing")
                    if sorted.count > 9 {
                        let numberToRemove = sorted.count - 9
                        for _ in 1...numberToRemove {
                            sorted.removeLast()
                        }
                    }
                    RecipeController.shared.allGroupsRecipes = sorted
                    completion()
                })
        }
    }
    
    
    // MARK: - Subscription
    
    
    func subscribeToBeingAddedToNewGroup() {
        
        guard let currentUser = currentUser, let userRecordID = currentUser.userRecordID else { return }
        
        let userReference = CKReference(recordID: userRecordID, action: .none)
        
        let predicate = NSPredicate(format: "userReferences CONTAINS %@", userReference)
        let notificationInfo = CKNotificationInfo()
//        notificationInfo.alertLocalizationKey = "You've Been Added to a new group"
//        notificationInfo.shouldBadge = false
        notificationInfo.shouldSendContentAvailable = true
        
        
        let subscription = CKQuerySubscription(recordType: "Group", predicate: predicate, options: .firesOnRecordUpdate)
        
        subscription.notificationInfo = notificationInfo
        
        CKContainer.default().publicCloudDatabase.save(subscription) { (subscription, error) in
            if let error = error {
                NSLog("\(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Profile Image Function
    
    func profileImageDisplay(imageView: UIImageView) {
        imageView.layer.borderWidth = 0.5
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.clipsToBounds = true
    }
}

