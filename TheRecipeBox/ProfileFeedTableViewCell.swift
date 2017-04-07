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
        guard let recipe = recipe else { return }
        recipePhotoImageView.image = recipe.recipeImage
        recipeNameLabel.text = recipe.name
        prepTimeLabel.text = recipe.prepTime
        servingSizeLabel.text = recipe.servingSize
        cookTimeLabel.text = recipe.cookTime
        RecipeController.shared.fetchProfileImageOfRecipeOwner(recipe: recipe) { (image) in
            DispatchQueue.main.async {
                self.profileImageView.image = image
            }
        }
        
    }
    
    
    // MARK: - UI Functions
    
    @IBAction func profileImageButtonTapped(_ sender: UIButton) {
        
    }

}
