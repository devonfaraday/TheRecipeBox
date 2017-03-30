//
//  GroupListTableViewController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/29/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class GroupListTableViewController: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GroupController.shared.fetchAllGroups {
            DispatchQueue.main.async {
                NSLog("Reloading TableView data")
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()

        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GroupController.shared.groups.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.groupCellIdentifier, for: indexPath)
        let group = GroupController.shared.groups[indexPath.row]
        cell.textLabel?.text = group.groupName
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow,
        let destinationVC = segue.destination  as? GroupDetailViewController else { return }

        let group = GroupController.shared.groups[indexPath.row]
        
        GroupController.shared.currentGroup = group
        destinationVC.group = group
        
    }
    
    @IBAction func addGroup(_ sender: Any) {
        
        
        
    }
    
    // MARK: - Add Group Alert Controller
    
    
    
    
    
    
}
