//
//  GroupRecipesTableViewController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/29/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class GroupRecipesTableViewController: UITableViewController {
    
    var recipes: [Recipe]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 198
        
        self.recipes = GroupController.shared.groupRecipes
        guard let group = GroupController.shared.currentGroup else { return }
        GroupController.shared.fetchRecipesIn(group: group) { (recipes) in
            DispatchQueue.main.async {
                self.recipes = recipes
                self.tableView.reloadData()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.recipes = GroupController.shared.groupRecipes
        tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let recipes = recipes else { return 0 }
        return recipes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.recipeCellIdentifier, for: indexPath) as? RecipeTableViewCell else { return RecipeTableViewCell() }
        
        let recipe = recipes?[indexPath.row]
        
        cell.recipe = recipe
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            guard let recipe = recipes?[indexPath.row],
                let group = GroupController.shared.currentGroup else { return }
            guard let index = recipes?.index(of: recipe) else { return }
            
            GroupController.shared.remove(recipe: recipe, fromGroup: group, completion: { (_) in
                DispatchQueue.main.async {
                    self.recipes?.remove(at: index)
                }
            })
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.toAddRecipeToGroupSegue {
            let destinationVC = segue.destination as? AddRecipesToGroupTableViewController
            destinationVC?.recipes = UserController.shared.currentRecipes
        }
        if segue.identifier == Constants.toShowRecipeSegue {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let destinationVC = segue.destination as? AddRecipeViewController
            destinationVC?.recipe = recipes?[indexPath.row]
        }
    }
    
    
}
