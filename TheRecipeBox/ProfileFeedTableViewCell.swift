//
//  ProfileFeedTableViewCell.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/13/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit
import CoreData

class ProfileFeedTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var recipePhotoImageView: UIImageView!
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var prepTimeLabel: UILabel!
    @IBOutlet weak var servingSizeLabel: UILabel!
    @IBOutlet weak var cookTimeLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var recipe: Recipe? {
        didSet {
            updateViews()
        }
    }
   
    
    // MARK: - Helper Functions
    
    func updateViews() {
        
    }
    
    
    // MARK: - UI Functions
    
    @IBAction func profileImageButtonTapped(_ sender: UIButton) {
    }

}
