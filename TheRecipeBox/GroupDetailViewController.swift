//
//  GroupDetailViewController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/29/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class GroupDetailViewController: UIViewController, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBOutlet weak var groupNameTextLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.userCellIdentifier, for: indexPath)
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.username
        
        return cell
    }
    
    // MARK: - UI Functions
    
    @IBAction func addUserButtonTapped(_ sender: Any) {
        guard let username = usernameTextField.text,
            let group = group else { return }
        UserController.shared.checkForUser(username: username) { (user) in
            UserController.shared.addUserToGroupRecord(user: user, group: group, completion: { (_) in
                DispatchQueue.main.async {
                    self.users.append(user)
                }
            })
        }
    }
    
    // MARK: - Helper Function
    
    func updateViews() {
        guard let group = group else { return }
        groupNameTextLabel.text = group.groupName
        GroupController.shared.fetchUsersIn(group: group) { (users) in
            DispatchQueue.main.async {
                self.users = users
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
    }
    
    
}
