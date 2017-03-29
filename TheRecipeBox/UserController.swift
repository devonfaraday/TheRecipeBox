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
    var currentUser: User? {
        didSet {
            NotificationCenter.default.post(name: currentUserWasSetNotification, object: nil)
        }
    }
    
    init() {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            guard let recordID = recordID else { return }
         self.appleUserRecordID = recordID
            self.CKManager.fetchCurrentUser { (currentUser) in
                self.currentUser = currentUser
            }
        }
    }
    func fetchRecipesForCurrentUser(completion: @escaping([Recipe]) -> Void) {
        guard let currentUser = currentUser else { return }
        guard let userID = currentUser.userRecordID else { return }
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
                currentUser.recipes = recipes
                completion(recipes)
            }
            
        }
    }
    
    func fetchGroupsForCurrentUser() {
        
    }
    
    func createUserWith(username: String, profilePhotoData: Data?, completion: @escaping (User?) -> Void) {
        
        guard let appleUserRecordID = appleUserRecordID,
              let profileImageData = profilePhotoData else { return }
        let appleUserRef = CKReference(recordID: appleUserRecordID, action: .deleteSelf)
        
        let user = User(username: username, profilePhotoData: profileImageData, appleUserRef: appleUserRef)
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

