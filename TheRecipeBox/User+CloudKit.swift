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
 
     convenience init?(cloudKitManager: CKRecord) {
        guard let fullName = cloudKitManager[Constants.userFullNameKey] as? String,
        let photoAsset = cloudKitManager[Constants.profileImageKey] as? CKAsset else { return nil }
        
        let imageData = try? Data(contentsOf: photoAsset.fileURL)
        self.init(fullName: fullName, profilePhotoData: imageData)
        self.profilePhotoData = imageData
        self.recipes = []
        self.userRecordID = cloudKitManager.recordID
    }
    
    fileprivate var temporaryPhotoURL: URL {
        
        let tempDir = NSTemporaryDirectory()
        let tempURL = URL(fileURLWithPath: tempDir)
        let fileURL = tempURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
        
        try? profilePhotoData?.write(to: fileURL, options: [.atomic])
        
        return fileURL
    }
}
