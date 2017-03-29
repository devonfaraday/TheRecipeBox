//
//  RecipeTableViewCell.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/14/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {

    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var prepTimeLabel: UILabel!
    @IBOutlet weak var servingsLabel: UILabel!
    @IBOutlet weak var cookTimeLabel: UILabel!
   
    var recipe: Recipe? {
        didSet{
            updateViews()
        }
    }
    
    func updateViews() {
        guard let recipe = recipe else { return }
        recipeNameLabel.text = recipe.name
        prepTimeLabel.text = recipe.prepTime
        servingsLabel.text = recipe.servingSize
        cookTimeLabel.text = recipe.cookTime
        DispatchQueue.main.async {
            self.recipeImageView.image = recipe.recipeImage
        }
    }
}
