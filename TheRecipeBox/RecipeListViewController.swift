//
//  RecipeListViewController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 5/16/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit
import CloudKit

class RecipeListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, RecipeCollectionViewCellDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectButton: UIBarButtonItem!
    
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
    var isAddingToGroup: Bool = false
    
    
    var selectedRecipes = [Recipe]()
    var isSelecting: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            if self.recipes.count < RecipeController.shared.currentRecipes.count {
            self.recipes = RecipeController.shared.currentRecipes
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipeCell", for: indexPath) as? RecipeCollectionViewCell else { return RecipeCollectionViewCell() }
        
        cell.layer.cornerRadius = 10
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 2
        cell.recipe = recipes[indexPath.row]
        cell.isSelectedButton.setBackgroundImage(nil, for: .normal)
        cell.delegate = self
        
        if isSelecting {
            cell.isSelectedButton.isHidden = false
        } else {
            cell.isSelectedButton.isHidden = true
        }
        
        return cell
    }
    @IBAction func selectButtonTapped(_ sender: RecipeCollectionViewCell) {
        
            if selectButton.title == "Delete" {
                
                for recipe in selectedRecipes {
                    guard let recordID = recipe.recordID,
                        let recipesIndex = recipes.index(of: recipe),
                        let sharedIndex = RecipeController.shared.currentRecipes.index(of: recipe)
                        else { return }
                    self.recipes.remove(at: recipesIndex)
                    RecipeController.shared.currentRecipes.remove(at: sharedIndex)
                    RecipeController.shared.deleteRecipeRecord(recipeID: recordID, completion: { (_) in
                    })
                }
                self.selectedRecipes = []
                self.selectButton.title = "Cancel"
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            } else {
                if isSelecting {
                    setToIsSelecting()
                } else {
                    setToIsCanceled()
                }
            }
        }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let recipe = recipes[indexPath.row]
        if !isAddingToGroup {
            performSegue(withIdentifier: "toShowRecipe", sender: self)
        }
        
        guard let recipeID = recipe.recordID, let currentGroup = GroupController.shared.currentGroup, let recipeRefs = currentGroup.recipeReferences else { return }
        let recipeRef = CKReference(recordID: recipeID, action: .none)
        if isAddingToGroup {
        if recipeRefs.contains(recipeRef) {
            self.allReadyAddedAlert()
        } else {
            GroupController.shared.add(recipe: recipe, toGroup: currentGroup) { (_) in
                print("recipe added to group")
                RecipeController.shared.allGroupsRecipes.append(recipe)
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        }
    }
    
    // MARK: - Recipe Delegate Method
    
    func isSelectedStatusChanged(_ sender: RecipeCollectionViewCell) {
        guard let recipe = sender.recipe
            else { return }
        
        if selectedRecipes.contains(recipe) {
            guard let index = selectedRecipes.index(of: recipe) else { return }
            selectedRecipes.remove(at: index)
        } else {
            selectedRecipes.append(recipe)
        }
        
        if isSelecting && !selectedRecipes.isEmpty {
            selectButton.title = "Delete"
        } else if isSelecting && selectedRecipes.isEmpty {
            selectButton.title = "Cancel"
        } else {
            selectButton.title = "Select"
        }
    }
    
    // MARK: - Helpers
    func setToIsSelecting() {
        isSelecting = false
        self.selectButton.title = "Select"
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func setToIsCanceled() {
        isSelecting = true
        selectButton.title = "Cancel"
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func allReadyAddedAlert()  {
        let alertController = UIAlertController(title: nil, message: "Recipe already added", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.toShowRecipeSegue {
            guard let indexPath = collectionView.indexPathsForSelectedItems else { return }
            let destinationVC = segue.destination as? AddRecipeViewController
            destinationVC?.recipe = recipes[indexPath[0].item]
        }
    }
    
    
}
