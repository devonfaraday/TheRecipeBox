//
//  UsernameViewController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/16/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit
import CloudKit

class UsernameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        CKContainer.default().accountStatus { (accountStatus, error) in
            if case .available = accountStatus {
                print("iCloud Available")
            } else {
                print("iCloud Unavailable")
            }
        }
         
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


/*
 
 If icloud user doen't have username stay on this page username is already created then move to Profile view
 
 */
