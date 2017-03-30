//
//  AddRecipesToGroupTableViewController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/29/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class AddRecipesToGroupTableViewController: UITableViewController {
    
    var recipes: [Recipe]? {
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
        recipes = UserController.shared.currentRecipes
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let recipes = recipes else { return 0 }
        return recipes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath)
        guard let recipes = recipes else { return UITableViewCell() }
        let recipe = recipes[indexPath.row]
        
        
        cell.imageView?.image = recipe.recipeImage
        cell.textLabel?.text = recipe.name
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let recipe = recipes?[indexPath.row] else { return }
        guard let currentGroup = GroupController.shared.currentGroup else { return }
        GroupController.shared.add(recipe: recipe, toGroup: currentGroup) { (_) in
            print("recipe added to group")
            self.alertController()
        }
    }
    
    func alertController() {
        let alertController = UIAlertController(title: "Recipe Added", message: nil, preferredStyle: .alert)
        let OkAction = UIAlertAction(title: "Ok", style: .cancel) { (_) in
            
        }
        alertController.addAction(OkAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    
}
