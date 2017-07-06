//
//  User+CloudKit.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/15/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

extension User {
 
     convenience init?(cloudKitRecord: CKRecord) {
        guard let username = cloudKitRecord[Constants.userusernameKey] as? String,
        let photoAsset = cloudKitRecord[Constants.profileImageKey] as? CKAsset,
        let appleUserRef = cloudKitRecord[Constants.defaultUserReferenceKey] as? CKReference else { return nil }
        
        let imageData = try? Data(contentsOf: photoAsset.fileURL)
        self.init(username: username, profilePhotoData: imageData, appleUserRef: appleUserRef)
        self.recipes = []
        self.userRecordID = cloudKitRecord.recordID
    }
    
     var temporaryPhotoURL: URL {
        
        let tempDir = NSTemporaryDirectory()
        let tempURL = URL(fileURLWithPath: tempDir)
        let fileURL = tempURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
        
        try? profilePhotoData?.write(to: fileURL, options: [.atomic])
        
        return fileURL
    }
    
    var cloudKitRecord: CKRecord {
        let record = CKRecord(recordType: Constants.userRecordType)
//        let recordID = userRecordID ?? CKRecordID(recordName: UUID().uuidString)
//        let record = CKRecord(recordType: Constants.userRecordType, recordID: recordID)
        record[Constants.defaultUserReferenceKey] = appleUserRef as CKRecordValue
        record[Constants.userusernameKey] = username as CKRecordValue
        record[Constants.profileImageKey] = CKAsset(fileURL: temporaryPhotoURL)
        
        return record
    }
}

extension CKRecord {
    convenience init(user: User) {
        let recordID = user.userRecordID ?? CKRecordID(recordName: UUID().uuidString)
        self.init(recordType: Constants.userRecordType, recordID: recordID)
        self.setValue(user.username, forKey: Constants.userusernameKey)
        self.setValue(CKAsset(fileURL: user.temporaryPhotoURL), forKey: Constants.profileImageKey)
        self.setValue(user.appleUserRef, forKey: Constants.defaultUserReferenceKey)
        
    }
}

