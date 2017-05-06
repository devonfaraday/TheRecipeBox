//
//  GroupRecipeCollectionViewCell.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 5/2/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class GroupRecipeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var prepTimeLabel: UILabel!
    @IBOutlet weak var servingsLabel: UILabel!
    @IBOutlet weak var cookTimeLabel: UILabel!
    @IBOutlet weak var recipeImageView: UIImageView!
    
    
    var recipe: Recipe? {
        didSet{
            updateViews()
        }
    }
    
    func updateViews() {
        guard let recipe = recipe else { return }
        DispatchQueue.main.async {
            self.recipeNameLabel.text = recipe.name
            self.prepTimeLabel.text = recipe.prepTime
            self.servingsLabel.text = recipe.servingSize
            self.cookTimeLabel.text = recipe.cookTime
            self.recipeImageView.image = recipe.recipeImage
            self.recipeImageView.layer.masksToBounds = true
        }
    }

}
