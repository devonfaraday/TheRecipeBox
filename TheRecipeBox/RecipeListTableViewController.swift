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
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
               
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.recipeCellIdentifier, for: indexPath) as? RecipeTableViewCell else { return RecipeTableViewCell() }
        
        let recipe = recipes[indexPath.row]
        
        cell.recipe = recipe
        
        return cell
    }
    
       override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
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
