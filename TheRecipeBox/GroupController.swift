//
//  GroupController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/17/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class GroupController {
    
    static let shared = GroupController()
    let publicDB = CKContainer.default().publicCloudDatabase
    
    var groups = [Group]()
    var currentGroup: Group?
    var groupRecipes: [Recipe] = []
    var userGroups: [Group] = []
    var users = [User]()
    
    
    
    func fetchGroupsForCurrent(user: User, completion: @escaping() -> Void = { _ in }) {
        guard let userID = user.userRecordID else { return }
        let predicate = NSPredicate(format: "userReferences CONTAINS %@", userID)
        let query = CKQuery(recordType: Constants.groupRecordType, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                NSLog("\(error.localizedDescription)")
                return
            } else {
                guard let records = records else { return }
                let groups = records.flatMap { Group(cloudKitRecord: $0) }
                
                self.userGroups = groups
                
                completion()
            }
        }
    }
    
    
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
        self.groups.append(group)
        self.userGroups.append(group)
        UserController.shared.userGroups.append(group)
        guard let user = UserController.shared.currentUser else { return }
        guard let userID = user.userRecordID else { return }
        let userReference = CKReference(recordID: userID, action: .none)
        
        let record = group.cloudKitRecord
        record.setValue([userReference], forKey: Constants.userReferencesKey)
        group.userReferences?.append(userReference)
        group.groupRecordID = record.recordID
        
        publicDB.save(record) { (_, error) in
            NSLog("Saving record for \(group.groupName)")
            if let error = error {
                print("Error here")
                completion(error)
            }
            NSLog("Performing completion for \(group.groupName)")
            completion(nil)
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
            self.users = users
            completion(users)
        }
    }
    
    func fetchRecipesIn(group: Group, completion: @escaping([Recipe]) -> Void = { _ in }) {
        var recipeRecordIDs = [CKRecordID]()
        var recipes = [Recipe]()
        guard let recipeReferences = group.recipeReferences else { return }
        for recipe in recipeReferences {
            let recipeID = recipe.recordID
            recipeRecordIDs.append(recipeID)
        }
        let group = DispatchGroup()
        for id in recipeRecordIDs {
            group.enter()
            publicDB.fetch(withRecordID: id, completionHandler: { (record, _) in
                guard let record = record else { return }
                guard let recipe = Recipe(cloudKitRecord: record) else { return }
                recipes.append(recipe)
                group.leave()
            })
        }
        group.notify(queue: DispatchQueue.main) {
            self.groupRecipes = recipes
            
            completion(recipes)
        }
    }
    
    func deleteGroup(recordID: CKRecordID, completion: @escaping((Error?) -> Void) = { _ in }) {
        publicDB.delete(withRecordID: recordID) { (_, error) in
            if let error = error {
                NSLog("Error deleting \(recordID)\n\(error.localizedDescription)")
            }
        }
    }
    
    func remove(user: User, fromGroup group: Group, completion: @escaping((Error?) -> Void) = { _ in }) {
        guard let userID = user.userRecordID,
            let groupID = group.groupRecordID else { return }
        publicDB.fetch(withRecordID: groupID) { (record, error) in
            if let error = error { NSLog("\(error.localizedDescription)"); completion(error) }
            if let record = record {
                let userReference = CKReference(recordID: userID, action: .none)
                guard let index = group.userReferences?.index(of: userReference) else { return }
                group.userReferences?.remove(at: index)
                record.setValue(group.userReferences, forKey: Constants.userReferencesKey)
                
                self.publicDB.save(record, completionHandler: { (_, error) in
                    if let error = error {
                        
                        print(error.localizedDescription)
                        completion(error)
                        
                    } else {
                        
                        print("saving recipe to group succeeded")
                        completion(nil)
                    }
                })
            }
        }
    }
    
    func add(recipe: Recipe, toGroup group: Group, completion: @escaping(Error?) -> Void) {
        
        guard let recipeID = recipe.recordID,
            let groupID = group.groupRecordID else { return }
        publicDB.fetch(withRecordID: groupID) { (record, error) in
            if let error = error { NSLog("\(error.localizedDescription)"); completion(error) }
            if let record = record {
                let recipeReference = CKReference(recordID: recipeID, action: .none)
                
                if group.recipeReferences != nil {
                    guard let gRecipeReferences = group.recipeReferences else { return }
                    
                    if !gRecipeReferences.contains(recipeReference) {
                        
                        group.recipeReferences?.append(recipeReference)
                        
                    } 
                
                } else {
                    group.recipeReferences = [recipeReference]
                }
                
                guard let recipeReferences = group.recipeReferences else { return }
                
                record.setValue(recipeReferences, forKey: Constants.recipeReferencesKey)
                
                self.publicDB.save(record, completionHandler: { (_, error) in
                    
                    if let error = error {
                        
                        print(error.localizedDescription)
                        completion(error)
                        
                    } else {
                        
                        print("saving recipe to group succeeded")
                        completion(nil)
                    }
                    
                })
            }
        }
    }
    
    func remove(recipe: Recipe, fromGroup group: Group, completion: @escaping ((Error?) -> Void) = { _ in }) {
        
        guard let recipeID = recipe.recordID,
            let groupID = group.groupRecordID else { return }
        let reference = CKReference(recordID: recipeID, action: .none)
        guard let refIndex = group.recipeReferences?.index(of: reference) else { return }
        group.recipeReferences?.remove(at: refIndex)
        publicDB.fetch(withRecordID: groupID) { (record, error) in
            guard let record = record else { return }
            record.setValue(group.recipeReferences, forKey: Constants.recipeReferencesKey)
            self.publicDB.save(record) { (record, error) in
                if let error = error {
                    print(error.localizedDescription)
                    completion(error)
                } else {
                    print("group record saved")
                    completion(nil)
                }
            }
            
        }
    }
    
    
   

}
