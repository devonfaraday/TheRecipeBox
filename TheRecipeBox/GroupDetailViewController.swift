//
//  GroupDetailViewController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/29/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class GroupDetailViewController: UIViewController, UITableViewDataSource, UITextFieldDelegate, UISearchBarDelegate, UITableViewDelegate {
    
    
    @IBOutlet weak var groupNameTextLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var leaveButton: UIButton!
    
    var searchActive: Bool = false
    var searchResults = [User]()
    
    var group: Group? {
        didSet {
            if !isViewLoaded {
                loadViewIfNeeded()
            }
            updateViews()
        }
    }
    
    var users: [User] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var groupRecipes = [Recipe]()
    var usernames: [String] {
        return users.map { $0.username }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.backgroundColor = .clear
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if group?.groupOwnerRef?.recordID == UserController.shared.currentUser?.userRecordID {
            leaveButton.setTitle("Delete Group", for: .normal)
        }
        if let group = group {
            GroupController.shared.fetchRecipesIn(group: group, completion: { (recipes) in
                self.groupRecipes = recipes
            })
        }
    }
    
    // MARK: - Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return searchResults.count
        } else {
            return users.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.userCellIdentifier, for: indexPath)
        // Making the image view of cell circular
        if let imageView = cell.imageView {
            UserController.shared.profileImageDisplay(imageView: imageView)
        }
        
        if searchActive {
            let searchedUser = searchResults[indexPath.row]
            cell.textLabel?.text = searchedUser.username
            
            if searchedUser.recipes != nil {
                cell.detailTextLabel?.text = ""
            }
        } else {
            let user = users[indexPath.row]
            DispatchQueue.main.async {
                cell.textLabel?.text = user.username
            }
//            if user.recipes != nil {
//                cell.detailTextLabel?.text = ""
//            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchActive {
        guard let group = group else { return }
        let user = searchResults[indexPath.row]
        let username = user.username
        if !usernames.contains(username) {
            
            UserController.shared.checkForUser(username: username) { (user) in
                UserController.shared.addUserToGroupRecord(user: user, group: group, completion: { (_) in
                    DispatchQueue.main.async {
                        self.users.append(user)
                    }
                })
            }
        }
        
        searchBar.text = nil
        searchActive = false
        tableView.reloadData()
        }
    }
    
    // MARK: - UI Functions
    
    @IBAction func leaveGroupButtonTapped(_ sender: Any) {
        if GroupController.shared.currentGroup?.groupOwnerRef?.recordID == UserController.shared.currentUser?.userRecordID {
            deletingGroupAlert()
        } else {
            leavingGroupAlert()
        }
    }
    
    // MARK: - Text Field Delegate Functions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    // MARK: - Search Bar Functions
    

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.text = nil
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = true
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.resignFirstResponder()
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchResults = UserController.shared.allUsers.filter({ (user) -> Bool in
            let username = user.username
            let range = username.contains(searchText)
            return range
        })
        if (searchResults.count == 0) {
            searchActive = false
        } else {
            searchActive = true
        }
        self.tableView.reloadData()
        
    }
    // MARK: - Helper Function
    
    func updateViews() {
        guard let group = group else { return }
        groupNameTextLabel.text = group.groupName

    }
    
    // MARK: - Alert Controllers
    
    func leavingGroupAlert() {
        let alertController = UIAlertController(title: "WARNING!", message: "You are about to leave this group.\nAre you sure?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            guard let user = UserController.shared.currentUser,
                let group = GroupController.shared.currentGroup,
                let index = GroupController.shared.userGroups.index(of: group)
            else { return }
            GroupController.shared.userGroups.remove(at: index)
            GroupController.shared.remove(user: user, fromGroup: group)
            
            
            _ = self.navigationController?.popViewController(animated: true)
        }
        let noAction = UIAlertAction(title: "No", style: .cancel) { (_) in
            
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func deletingGroupAlert() {
        let alertController = UIAlertController(title: "WARNING!", message: "You are about to delete this group.\nAre you sure?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            guard let group = GroupController.shared.currentGroup,
                let groupID = group.groupRecordID
                else { return }
           GroupController.shared.deleteGroup(recordID: groupID, completion: { (error) in
            if error != nil {
                NSLog("Error deleting group")
            } else {
                guard let index = GroupController.shared.userGroups.index(of: group) else { return }
                GroupController.shared.userGroups.remove(at: index)
                DispatchQueue.main.async {
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
           })
            
            
            
        }
        let noAction = UIAlertAction(title: "No", style: .cancel) { (_) in
            
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        present(alertController, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGroupRecipeList" {
            guard let destination = segue.destination as? GroupRecipeViewController else { return }
            destination.recipes = groupRecipes
        }
    }
    
}
