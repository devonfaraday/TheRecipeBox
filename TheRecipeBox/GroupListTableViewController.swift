//
//  GroupListTableViewController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/29/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit
import NotificationCenter

class GroupListTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(performUpdate), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(performUpdate), name: Constants.groupDidChangeNotificationName, object: nil)
        tableView.refreshControl = refreshControl
        self.navigationController?.navigationBar.backgroundColor = .clear
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: - Data Source
    
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
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        let group = GroupController.shared.userGroups[indexPath.row]
        if UserController.shared.currentUser?.userRecordID == group.groupOwnerRef?.recordID {
            return .delete
        } else {
            return .none
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow,
            let destinationVC = segue.destination  as? GroupDetailViewController else { return }
        
        let group = GroupController.shared.userGroups[indexPath.row]
        GroupController.shared.fetchUsersIn(group: group) { (users) in
            DispatchQueue.main.async {
                destinationVC.users = users
            }
        }
        GroupController.shared.fetchRecipesIn(group: group) { (recipes) in
                GroupController.shared.groupRecipes = recipes
        }
        GroupController.shared.currentGroup = group
        destinationVC.group = group
        
    }
    
    @IBAction func addGroup(_ sender: Any) {
        
    }
    
    // MARK: - Notification Update Function
    
    func performUpdate() {
        guard let currentUser = UserController.shared.currentUser else { return }
        GroupController.shared.fetchGroupsForCurrent(user: currentUser) {
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.view.layoutSubviews()
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
}
