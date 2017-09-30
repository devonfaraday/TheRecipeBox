//
//  MenuViewController.swift
//  SideMenu
//
//  Created by Christian McMullin on 8/16/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    
    let navOptions = ["Sparks", "Embers", "Elements", "Path", "People", "Profile"]

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return navOptions.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "menu", for: indexPath) as? MenuTableViewCell else { return UITableViewCell() }
        let item = navOptions[indexPath.row]
        
        
        cell.itemLabel.text = item
        
        return cell
    }

}
