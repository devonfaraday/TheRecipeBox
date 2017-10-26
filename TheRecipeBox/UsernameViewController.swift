//
//  UsernameViewController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/16/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit
import CloudKit

class UsernameViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tapToUploadButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var loadingView: UIView!
    
    let CKManager = CloudKitManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.isHidden = true
        setupImageView()
    }
    
    // MARK: - Image Picker Delegate Functions
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        profileImageView.image = selectedImage
        tapToUploadButton.setTitle("", for: .normal)
        dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: - Text Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - UI Functions
    @IBAction func submitButtonTapped(_ sender: Any) {
        
        guard let username = usernameTextField.text else { return }
        if let image = profileImageView.image {
            guard let imageData = UIImageJPEGRepresentation(image, 0.5) else { return }
            submitButton.isEnabled = false
            loadingView.isHidden = false
            LoadingIndicatorView.show(loadingView, loadingText: "Creating Your Account")
            UserController.shared.createUserWith(username: username, profilePhotoData: imageData, completion: { (_) in
                print("saved with image")
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toProfile", sender: self)
                    LoadingIndicatorView.hide()
                }
            })
//            UserController.shared.subscribeToBeingAddedToNewGroup()
        } else {
            addPhotoAlert()
        }
    }
    
    @IBAction func tapToUploadButtonTapped(_ sender: Any) {
        usernameTextField.resignFirstResponder()
        addPhotoActionSheet()
    }
    
    func addPhotoActionSheet() {
        let actionController = UIAlertController(title: "Upload Photo", message: nil, preferredStyle: .actionSheet)
        let uploadAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            self.uploadButton()
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.cameraButton()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary)  &&  UIImagePickerController.isSourceTypeAvailable(.camera){
            actionController.addAction(uploadAction)
            actionController.addAction(cameraAction)
        } else if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionController.addAction(cameraAction)
        } else if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            actionController.addAction(uploadAction)
        }
        actionController.addAction(cancelAction)
        
        present(actionController, animated: true, completion: nil)
    }
    
    // MARK: - functions for upload or camera
    
    func uploadButton() {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func cameraButton() {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.sourceType = .camera
        
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
        
    }

    func addPhotoAlert() {
        let alertController = UIAlertController(title: "WARNING!", message: "Must add photo", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel) { (_) in
            
        }
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func setupImageView() {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.masksToBounds = true
    }
}



// MARK: - Push funciton


