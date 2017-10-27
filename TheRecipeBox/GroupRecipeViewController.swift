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
    var group: Group?
    var recipes = [Recipe]() {
        didSet {
            if !isViewLoaded {
                loadViewIfNeeded()
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let group = GroupController.shared.currentGroup {
        getNewRecipes()
       self.title = group.groupName
        }
        self.navigationController?.navigationBar.backgroundColor = .clear
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipeCell", for: indexPath) as? GroupRecipeCollectionViewCell else { return GroupRecipeCollectionViewCell() }
        
        cell.layer.cornerRadius = 10
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 1
        cell.recipe = recipes[indexPath.row]
        
        return cell
    }

    @IBAction func addRecipesToGroupButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: .toRecipeListViewControllerSegue, sender: self)
    }
    
    func getNewRecipes() {
        if recipes.count < GroupController.shared.groupRecipes.count {
            recipes = GroupController.shared.groupRecipes
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String.toRecipeListViewControllerSegue {
            guard let destination = segue.destination as? RecipeListViewController else { return }
            destination.isAddingToGroup = true
        }
        if segue.identifier == Constants.toShowRecipeSegue {
            
            guard let indexPath = collectionView.indexPathsForSelectedItems else { return }
            let destinationVC = segue.destination as? AddRecipeViewController
            destinationVC?.recipe = GroupController.shared.groupRecipes[indexPath[0].item]
        }
    }

}

