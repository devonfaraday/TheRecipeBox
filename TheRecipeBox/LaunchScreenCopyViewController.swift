//
//  LaunchScreenCopyViewController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/28/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit
import CloudKit

class LaunchScreenCopyViewController: UIViewController {
    
    var cloudKitManager = CloudKitManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        cloudKitManager.fetchCurrentUser { (user) in
            if user != nil {
                guard let user = user else { return }
                print("Fetching recipes in launch screen")
                UserController.shared.fetchGroupsRecipesFor(user: user, completion: { () in
                    print("Recipes fetched")
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: Constants.toProfileSegue, sender: self)
                    }
                    
                })
            } else {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: Constants.toUserCreationSegue, sender: self)
                }
            }
        }
        
        
    }
}
