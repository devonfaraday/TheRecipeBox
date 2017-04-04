//
//  GroupListTableViewController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/29/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class GroupListTableViewController: UITableViewController {
    
    
    var userGroups = [Group]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GroupController.shared.userGroups.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.groupCellIdentifier, for: indexPath)
        let group = GroupController.shared.userGroups[indexPath.row]
        
        cell.textLabel?.text = group.groupName
        if let userReferences = group.userReferences {
            cell.detailTextLabel?.text = "\(userReferences.count) Members"
        } else {
            cell.detailTextLabel?.isHidden = true
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let group = GroupController.shared.userGroups[indexPath.row]
            guard let recordID = group.groupRecordID,
                let index = GroupController.shared.userGroups.index(of: group) else { return }
            GroupController.shared.deleteGroup(recordID: recordID)
            GroupController.shared.userGroups.remove(at: index)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow,
            let destinationVC = segue.destination  as? GroupDetailViewController else { return }
        
        let group = GroupController.shared.userGroups[indexPath.row]
        GroupController.shared.fetchRecipesIn(group: group) { (recipes) in
            DispatchQueue.main.async {
                GroupController.shared.groupRecipes = recipes
            }
        }
        GroupController.shared.currentGroup = group
        destinationVC.group = group
        
    }
    
    @IBAction func addGroup(_ sender: Any) {
        
    }
    
    // MARK: - Add Group Alert Controller
    
}
