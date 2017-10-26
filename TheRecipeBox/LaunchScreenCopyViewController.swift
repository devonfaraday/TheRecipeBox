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
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        cloudKitManager.fetchCurrentUser { (user, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorAlert(withTitle: "Error", message: error.localizedDescription)
                }
            } else {
                if user != nil {
                    guard let user = user else { return }
                    print("Fetching recipes in launch screen")
                    UserController.shared.fetchGroupsRecipesFor(user: user, completion: { () in
                        self.segueToProfile()
                    })
                } else {
                    self.segueToUserCreation()
                }
            }
        }
    }
    
    func segueToProfile() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: Constants.toProfileSegue, sender: self)
        }
    }
    
    func segueToUserCreation() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: Constants.toUserCreationSegue, sender: self)
        }
    }
    
    func errorAlert(withTitle title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
}
