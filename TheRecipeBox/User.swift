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

class User {
    
    var fullName: String
    var userRecordID: CKRecordID?
    var profilePhotoData: Data?
    var recipes: [Recipe]
    
    var profilePhoto: UIImage {
        guard let imageData = profilePhotoData,
            let image = UIImage(data: imageData) else { return UIImage() }
        return image
    }
    
    init(fullName: String, recipes: [Recipe] = [], profilePhotoData: Data? = nil) {
        self.fullName = fullName
        self.recipes = recipes
        self.profilePhotoData = profilePhotoData
    }
    
}
