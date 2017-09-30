//
//  ProfileViewController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/13/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit
import CloudKit

class ProfileViewController: UIViewController, UITableViewDataSource {
    
    // MARK: - Properties
    let CKManager = CloudKitManager()
    var currentUser: User?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var addProfileImageButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followingNumberLabel: UILabel!
    @IBOutlet weak var recipesNumberLabel: UILabel!
    @IBOutlet weak var groupsNumberLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(performUpdate), for: UIControlEvents.valueChanged)
        tableView.refreshControl = refreshControl
        self.navigationController?.navigationBar.backgroundColor = .clear
        
        CKManager.fetchCurrentUser { (user) in
            guard let user = user else {  return  }
            
            DispatchQueue.main.async {
                UserController.shared.currentUser = user
                self.currentUser = user
                self.nameLabel.text = user.username
                self.profileImageView.image = user.profilePhoto
            }
            UserController.shared.subscribeToBeingAddedToNewGroup()
            
            UserController.shared.fetchRecipesForCurrent(user: user, completion: { (recipes) in
                DispatchQueue.main.async {
                    RecipeController.shared.currentRecipes = recipes
                    self.recipesNumberLabel.text = "\(RecipeController.shared.currentRecipes.count)"
                }
            })
            
            GroupController.shared.fetchGroupsForCurrent(user: user) {
                DispatchQueue.main.async {
                    self.groupsNumberLabel.text = "\(GroupController.shared.userGroups.count)"
                }
            }
        }
         UserController.shared.profileImageDisplay(imageView: profileImageView)
     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         NotificationCenter.default.addObserver(self, selector: #selector(performUpdate), name: Constants.groupDidChangeNotificationName, object: nil)
        guard let currentUser = UserController.shared.currentUser else { return }
        DispatchQueue.main.async {
            self.nameLabel.text =  currentUser.username
            self.profileImageView.image = currentUser.profilePhoto
            self.recipesNumberLabel.text = "\(RecipeController.shared.currentRecipes.count)"
            self.groupsNumberLabel.text = "\(GroupController.shared.userGroups.count)"
            UserController.shared.profileImageDisplay(imageView: self.profileImageView)
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Constants.groupDidChangeNotificationName, object: nil)
    }
    
    // MARK: - Table view dataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RecipeController.shared.allGroupsRecipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.profileFeedIdentifier, for: indexPath) as? ProfileFeedTableViewCell else { return ProfileFeedTableViewCell() }
        cell.loadingIndicator.startAnimating()
        let recipe = RecipeController.shared.allGroupsRecipes[indexPath.row]
        
        cell.layer.borderWidth = 6
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.cornerRadius = 25
        cell.recipe = recipe
        
        
        return cell
    }
    
    // MARK: - UI Functions
    
    @IBAction func addProfileImageButtonTapped(_ sender: UIButton) {
        
    }
    
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRecipeFromProfile" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            guard let destinationVC = segue.destination as? AddRecipeViewController else { return }
            let recipe = RecipeController.shared.allGroupsRecipes[indexPath.row]
            destinationVC.recipe = recipe
        }
    }
    
    // MARK: - Helpers
    
    func performUpdate() {
        guard let user = currentUser else { return }
        GroupController.shared.fetchGroupsForCurrent(user: user) {
            DispatchQueue.main.async {
                self.groupsNumberLabel.text = "\(GroupController.shared.userGroups.count)"
                UserController.shared.fetchGroupsRecipesFor(user: user, completion: { () in
                    self.reloadTableDataOnMainQueue()
                })
            }
        }
    }
    func reloadTableDataOnMainQueue() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        }
    }
}
