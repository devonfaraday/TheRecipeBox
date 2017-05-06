//
//  GroupRecipeViewController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 5/3/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class GroupRecipeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return GroupController.shared.groupRecipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipeCell", for: indexPath)
    }
    
}
