//
//  RequestTableViewController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 5/15/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class RequestTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var requestTextView: UITextView!
    
    // MARK: - UI Actions
    @IBAction func segmentSelected(_ sender: Any) {
        
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        guard let request = requestTextView.text else { return }
        if segmentedControl.selectedSegmentIndex == 0 {
            if let email = emailTextField.text {
                BugController.shared.createbugWith(bug: request, andEmail: email, completion: {
                    print("Bug fix requested")
                })
            } else {
                BugController.shared.createbugWith(bug: request, completion: {
                    print("Bug fix request with email")
                })
            }
        } else {
            if let email = emailTextField.text {
                FeatureController.shared.createFeatureWith(feature: request, andEmail: email, completion: {
                    print("Feature Requested")
                })
            } else {
                FeatureController.shared.createFeatureWith(feature: request, completion: {
                    print("Feature requested with email")
                })
            }
        }
    }
}
