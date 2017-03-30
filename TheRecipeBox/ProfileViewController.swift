//
//  ProfileViewController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/13/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource {
    
    // MARK: - Properties
    let CKManager = CloudKitManager()
    let userController = UserController()
    let groupController = GroupController()
    var recipes = [Recipe]()
    var userGroups = [Group]()
    
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
                self.nameLabel.text = user.username
                self.profileImageView.image = user.profilePhoto
            }
        }
        userController.fetchRecipesForCurrentUser { (recipes) in
            DispatchQueue.main.async {
                self.recipesNumberLabel.text = "\(recipes.count)"
                self.recipes = recipes
            }
        }
        guard let user = userController.currentUser else { return }
        groupController.fetchGroupsForCurrent(user: user) { 
            DispatchQueue.main.async {
                self.groupsNumberLabel.text = "\(self.groupController.userGroups.count)"
                self.userGroups = self.groupController.userGroups
            }
        }
        
        profileImageDisplay()
        
    }
    
    // MARK: - Table view dataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.profileFeedIdentifier, for: indexPath) as? ProfileFeedTableViewCell else { return ProfileFeedTableViewCell() }
        
        
        return cell
    }
    
    // MARK: - UI Functions
    
    @IBAction func addProfileImageButtonTapped(_ sender: UIButton) {
        
    }
    
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.toRecipeList {
        guard let destinationVC = segue.destination as? RecipeListTableViewController else { return }
        
        destinationVC.recipes = recipes
        }
        if segue.identifier == Constants.toGroupListSegue {
            guard let destinationVC = segue.destination as? GroupListTableViewController else { return }
            destinationVC.userGroups = userGroups
        }
    }
    
    func profileImageDisplay() {
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
    }
}
