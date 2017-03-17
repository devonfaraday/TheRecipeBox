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
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var addProfileImageButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followingNumberLabel: UILabel!
    @IBOutlet weak var recipesNumberLabel: UILabel!
    @IBOutlet weak var groupsNumberLabel: UILabel!
    
    
    
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
        
    }
}
