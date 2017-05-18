//
//  RecipeCollectionCollectionViewCell.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 5/16/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class RecipeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var prepTimeLabel: UILabel!
    @IBOutlet weak var servingsLabel: UILabel!
    @IBOutlet weak var cookTimeLabel: UILabel!
    @IBOutlet weak var isSelectedButton: UIButton!
    
    var recipe: Recipe? {
        didSet{
            updateViews()
        }
    }
    
    var delegate: RecipeCollectionViewCellDelegate?
    
    func updateViews() {
        guard let recipe = recipe else { return }
        DispatchQueue.main.async {
            self.recipeNameLabel.text = recipe.name
            self.prepTimeLabel.text = recipe.prepTime
            self.servingsLabel.text = recipe.servingSize
            self.cookTimeLabel.text = recipe.cookTime
            self.recipeImageView.image = recipe.recipeImage
            self.recipeImageView.layer.masksToBounds = true
            self.isSelectedButton.layer.cornerRadius = 5
        }
    }
    
    @IBAction func isSelectedButtonTapped(_ sender: Any) {
        delegate?.isSelectedStatusChanged(self)
        if !isSelected {
            isSelected = true
            isSelectedButton.setBackgroundImage(#imageLiteral(resourceName: "CheckMark"), for: .normal)
        } else {
            isSelected = false
            isSelectedButton.setBackgroundImage(nil, for: .normal)
        }
    }

}

protocol RecipeCollectionViewCellDelegate {
    func isSelectedStatusChanged(_ sender: RecipeCollectionViewCell)
}
