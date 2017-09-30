//
//  AddGroupViewController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/29/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit
import NotificationCenter

class AddGroupViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, MemberCollectionViewCellDelegate, UITextFieldDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var groupNameTextField: UITextField!
    var usersToAdd = [User]()
    var searchActive: Bool = false
    var searchResults = [User]()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!

    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundImageView.addSubview(blurView)
        self.navigationController?.navigationBar.backgroundColor = .clear
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - IBActions
    
    @IBAction func save(_ sender: Any) {
        guard let groupName = groupNameTextField.text else { return }
        if !groupName.isEmpty {
            let group = GroupController.shared.createGroupWith(name: groupName)
            GroupController.shared.saveToCloudKit(group: group, withUsers: usersToAdd, completion: { (_) in
            })
            NSLog("Popping view controller")
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            noGroupNameAlert()
        }
    }
    
    // MARK: - Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchActive {
            return searchResults.count
        } else {
            return UserController.shared.allUsers.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.memberImageIdentifier, for: indexPath) as? MemberCollectionViewCell else { return MemberCollectionViewCell() }
        
        if searchActive {
            
            let user = searchResults[indexPath.row]
            cell.user = user
            
        } else {
            
            let user = UserController.shared.allUsers[indexPath.row]
            cell.user = user
        }
        
        cell.delegate = self
        
        return cell
    }
    
    // MARK: - Member Collection View Delegate Function
    
    func checkMarkButtonTapped(_ sender: MemberCollectionViewCell) {
        guard let user = sender.user else { return }
        if !sender.isChecked {
            usersToAdd.append(user)
        } else {
            if usersToAdd.contains(user) {
                guard let index = usersToAdd.index(of: user) else { return }
                usersToAdd.remove(at: index)
            }
        }
        
    }
    
    // MARK: - Search Bar Delegate Methods
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.text = nil
        searchBar.resignFirstResponder()
        DispatchQueue.main.async {
        self.collectionView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = true
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchResults = UserController.shared.allUsers.filter({ (user) -> Bool in
            let username = user.username
            let range = username.contains(searchText)
            return range
        })
        if (searchResults.count == 0) {
            searchActive = false
        } else {
            searchActive = true
        }
        DispatchQueue.main.async {
        self.collectionView.reloadData()
        }
        
    }
    
    // MARK: - Text Field Delegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - CALayer Filter
    
    func bluryFilter() {
        let layer = CALayer()
        
        if let filter = CIFilter(name: "CIGaussianBlur") {
            filter.name = "blur"
            layer.backgroundFilters = [filter]
            layer.setValue(1, forKey: "backgroundFilters.myFilter.inputRadius")
        }
    }
    
    
    
    // MARK: - Keyboard functions
    
    
    func keyboardWillShow(notification: NSNotification) {
        
        guard let tabHeight = tabBarController?.tabBar.layer.frame.height else { return }
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            collectionViewBottomConstraint.constant = collectionViewBottomConstraint.constant + keyboardSize.height - tabHeight
            
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        guard let tabHeight = tabBarController?.tabBar.layer.frame.height else { return }
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {

            collectionViewBottomConstraint.constant = collectionViewBottomConstraint.constant - keyboardSize.height + tabHeight
            
        }
    }
    
    // MARK: - Alert Controller
    
    func noGroupNameAlert() {
        let alertController = UIAlertController(title: "No Name", message: "Enter a group name.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }


}
