//
//  AddGroupViewController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/29/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class AddGroupViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MemberCollectionViewCellDelegate {
    
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
    
    // MARK: - Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserController.shared.allUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.memberImageIdentifier, for: indexPath) as? MemberCollectionViewCell else { return MemberCollectionViewCell() }
        let user = UserController.shared.allUsers[indexPath.row]
        
        cell.user = user
        
        return cell
    }
    
    // MARK: - Member Collection View Delegate Function
    
    func checkMarkButtonTapped(_ sender: MemberCollectionViewCell) {
        
    }
}
