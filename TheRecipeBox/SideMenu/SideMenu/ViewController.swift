//
//  ViewController.swift
//  SideMenu
//
//  Created by Christian McMullin on 8/16/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var menuTableView = MenuViewController()
    var isNavigating: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTableView = self.storyboard?.instantiateViewController(withIdentifier: "menuViewController") as! MenuViewController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func menu(_ sender: Any) {
        if isNavigating {
            showMenu()
        } else {
            closeMenu()
        }
    }

    func showMenu() {
        
        UIView.animate(withDuration: 0.3) { 
            
            self.menuTableView.view.frame = CGRect(x: 0, y: 60, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            self.addChildViewController(self.menuTableView)
            self.view.addSubview(self.menuTableView.view)
            self.isNavigating = false
        }
        
    }
    
    func closeMenu() {
        UIView.animate(withDuration: 0.3) {
             self.menuTableView.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 60, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            self.menuTableView.view.removeFromSuperview()
            self.isNavigating = true
            
        }
    }

}

