//
//  MemberCollectionViewCell.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 4/22/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class MemberCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var checkMarkImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    var delegate: MemberCollectionViewCellDelegate?
    var user: User? {
        didSet {
            updateView()
        }
    }
    
    @IBAction func checkButtonTapped(_ sender: Any) {
        delegate?.checkMarkButtonTapped(self)
    }
    
    func updateView() {
        guard let user = user else { return }
        DispatchQueue.main.async {
        self.userImageView.image = user.profilePhoto
            self.usernameLabel.text = user.username
            UserController.shared.profileImageDisplay(imageView: self.userImageView)
        }
    }
    
}

protocol MemberCollectionViewCellDelegate {
    func checkMarkButtonTapped(_ sender: MemberCollectionViewCell)
}
