//
//  GroupRecipeViewController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 5/3/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class GroupRecipeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let group = GroupController.shared.currentGroup else { return }
        self.title = group.groupName
        self.navigationController?.navigationBar.backgroundColor = .clear
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return GroupController.shared.groupRecipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipeCell", for: indexPath) as? GroupRecipeCollectionViewCell else { return GroupRecipeCollectionViewCell() }
        
        cell.layer.cornerRadius = 10
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 1
        cell.recipe = GroupController.shared.groupRecipes[indexPath.row]
        
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//       performSegue(withIdentifier: Constants.toShowRecipeSegue, sender: self)
//        
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.toAddRecipeToGroupSegue {
            let destinationVC = segue.destination as? AddRecipesToGroupTableViewController
            destinationVC?.recipes = RecipeController.shared.currentRecipes
        }
        if segue.identifier == Constants.toShowRecipeSegue {
            
//            guard let indexPath =  collectionView.indexPath(for: GroupRecipeCollectionViewCell()) else { return }
            guard let indexPath = collectionView.indexPathsForSelectedItems else { return }
            let destinationVC = segue.destination as? AddRecipeViewController
            destinationVC?.recipe = GroupController.shared.groupRecipes[indexPath[0].item]
        }
    }

}

