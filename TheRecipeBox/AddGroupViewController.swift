//
//  AddGroupViewController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/29/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class AddGroupViewController: UIViewController {
    
    @IBOutlet weak var groupNameTextField: UITextField!
    
    @IBAction func save(_ sender: Any) {
        guard let groupName = groupNameTextField.text else { return }
        if !groupName.isEmpty {
            let group = GroupController.shared.createGroupWith(name: groupName)
            GroupController.shared.saveToCloudKit(group: group, completion: { (_) in
                NSLog("Popping view controller")
            })
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
}
