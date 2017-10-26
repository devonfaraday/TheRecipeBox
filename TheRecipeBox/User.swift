//
//  User.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/15/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class User: Equatable {
    
    var username: String
    var userRecordID: CKRecordID?
    var profilePhotoData: Data?
    var recipes: [Recipe]?
    
    var appleUserRef: CKReference
    
    
    var profilePhoto: UIImage {
        guard let imageData = profilePhotoData,
            let image = UIImage(data: imageData) else { return UIImage() }
        return image
    }
    
    init(username: String, recipes: [Recipe] = [], profilePhotoData: Data? = nil, appleUserRef: CKReference) {
        self.username = username
        self.recipes = recipes
        self.profilePhotoData = profilePhotoData
        self.appleUserRef = appleUserRef
    }
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.userRecordID?.recordName == rhs.userRecordID?.recordName
}
