//
//  RecipeListTableViewController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/14/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class RecipeListTableViewController: UITableViewController {
    
    var recipes = [Recipe]() {
        didSet {
            if !isViewLoaded {
                loadViewIfNeeded()
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.recipes = RecipeController.shared.currentRecipes
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.recipeCellIdentifier, for: indexPath) as? RecipeTableViewCell else { return RecipeTableViewCell() }
        
        let recipe = recipes[indexPath.row]
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        cell.recipe = recipe
        
        return cell
    }
    
       override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let recipe = recipes[indexPath.row]
            
            guard let recordID = recipe.recordID,
            let index = recipes.index(of: recipe) else { return }
            RecipeController.shared.deleteRecipeRecord(recipeID: recordID)
            recipes.remove(at: index)
            RecipeController.shared.currentRecipes.remove(at: index)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        if segue.identifier == Constants.toShowRecipeSegue {
            guard let detailVC = segue.destination as? AddRecipeViewController else { return }
                let recipe = self.recipes[indexPath.row]
            
            detailVC.recipe = recipe
           
        }
    }
}
