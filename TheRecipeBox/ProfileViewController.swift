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
    var allGroupsRecipes = [Recipe]()
    
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var addProfileImageButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followingNumberLabel: UILabel!
    @IBOutlet weak var recipesNumberLabel: UILabel!
    @IBOutlet weak var groupsNumberLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // segue from recipes button to recipe list without a second network call.
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        CKManager.fetchCurrentUser { (user) in
            guard let user = user else {  return  }
            
            DispatchQueue.main.async {
                UserController.shared.currentUser = user
                self.nameLabel.text = user.username
                self.profileImageView.image = user.profilePhoto
            }
            UserController.shared.subscribeToBeingAddedToNewGroup()
            
            UserController.shared.fetchRecipesForCurrent(user: user, completion: { (recipes) in
                DispatchQueue.main.async {
                    UserController.shared.currentRecipes = recipes
                    self.recipesNumberLabel.text = "\(UserController.shared.currentRecipes.count)"
                }
            })
            
            GroupController.shared.fetchGroupsForCurrent(user: user) {
                DispatchQueue.main.async {
                    self.groupsNumberLabel.text = "\(GroupController.shared.userGroups.count)"
                    UserController.shared.userGroups = GroupController.shared.userGroups
                }
            }
            UserController.shared.fetchGroupsRecipesFor(user: user, completion: { (recipes) in
                DispatchQueue.main.async {
                    self.allGroupsRecipes = recipes
                    self.tableView.reloadData()
                }
            })
        }
        
       
        NotificationCenter.default.addObserver(self, selector: #selector(performUpdate), name: Constants.groupDidChangeNotificationName, object: nil)
        
        profileImageDisplay()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentUser = UserController.shared.currentUser
        DispatchQueue.main.async {
            self.nameLabel.text = self.currentUser?.username
            self.profileImageView.image = self.currentUser?.profilePhoto
            self.recipesNumberLabel.text = "\(UserController.shared.currentRecipes.count)"
            self.groupsNumberLabel.text = "\(GroupController.shared.userGroups.count)"
            self.profileImageDisplay()
        }
    }
    
    // MARK: - Table view dataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserController.shared.allGroupsRecipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.profileFeedIdentifier, for: indexPath) as? ProfileFeedTableViewCell else { return ProfileFeedTableViewCell() }
        
        let recipe = UserController.shared.allGroupsRecipes[indexPath.row]
        
        cell.recipe = recipe
        
        
        
        
        
        return cell
    }
    
    // MARK: - UI Functions
    
    @IBAction func addProfileImageButtonTapped(_ sender: UIButton) {
        
    }
    
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.toRecipeList {
            //        guard let destinationVC = segue.destination as? RecipeListTableViewController else { return }
            
            //        destinationVC.recipes = UserController.shared.currentRecipes
        }
        if segue.identifier == "toRecipeFromProfile" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
           guard let destinationVC = segue.destination as? AddRecipeViewController else { return }
            let recipe = allGroupsRecipes[indexPath.row]
             destinationVC.recipe = recipe
        }
    }
    
    func profileImageDisplay() {
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
    }
    
    // MARK: - Helpers
    
    func performUpdate() {
        guard let user = currentUser else { return }
        GroupController.shared.fetchGroupsForCurrent(user: user) {
            DispatchQueue.main.async {
                self.groupsNumberLabel.text = "\(GroupController.shared.userGroups.count)"
                UserController.shared.userGroups = GroupController.shared.userGroups
                self.tableView.reloadData()
            }
        }
    }
}
