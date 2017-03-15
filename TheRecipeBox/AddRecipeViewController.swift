//
//  AddRecipeViewController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/14/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class AddRecipeViewController: UIViewController, UITableViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recipeImageView.layer.masksToBounds = true
    }
    
    // MARK: - Properties
    let sections = ["Ingredients", "Instructions"]
    
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeNameTextField: UITextField!
    @IBOutlet weak var prepTimeTextField: UITextField!
    @IBOutlet weak var servingsTextField: UITextField!
    @IBOutlet weak var cookTimeTextField: UITextField!
    @IBOutlet weak var ingredientTextField: UITextField!
    @IBOutlet weak var instructionTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addPhotoButton: UIButton!
    var ingredients = [Ingredient]()
    var instructions = [Instruction]()
    
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
        return "\(sections[0])"
        } else {
            return "\(sections[1])"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return ingredients.count
        } else {
            return instructions.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.addRecipeCellIdentifier, for: indexPath)
        
        if indexPath.section == 0 {
            let ingredient = ingredients[indexPath.row]
            cell.textLabel?.text = ingredient.nameAndAmount
            
        } else {
            let instruction = instructions[indexPath.row]
            cell.textLabel?.text = "\(indexPath.row + 1):  \(instruction.instruction)"
            
        }
        
        return cell
    }
    
    
    // MARK: - Image Picker Delegate Functions
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        recipeImageView.image = selectedImage
        addPhotoButton.setTitle("", for: .normal)
        dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: - UI Functions
    
    
    @IBAction func addIngredientButtonTapped(_ sender: Any) {
        guard let ingredient = ingredientTextField.text else { return }
        let newIngredient = Ingredient(nameAndAmount: ingredient)
        ingredients.append(newIngredient)
        ingredientTextField.text = ""
        tableView.reloadData()
    }
    
    
    @IBAction func addInstructionButtonTapped(_ sender: Any) {
        guard let instruction = instructionTextField.text else { return }
        let newInstruction = Instruction(instruction: instruction)
        instructions.append(newInstruction)
        instructionTextField.text = ""
        tableView.reloadData()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let name = recipeNameTextField.text,
            let prepTime = prepTimeTextField.text,
            let servings = servingsTextField.text,
            let cookTime = cookTimeTextField.text
        else { return }
        if let image = recipeImageView.image {
            let imageData = UIImagePNGRepresentation(image)
            let recipe = Recipe(name: name, prepTime: prepTime, servingSize: servings, cookTime: cookTime, recipeImageData: imageData)
            RecipeController.shared.addRecipeToCloudKit(recipe: recipe, ingredients: ingredients, instructions: instructions)
        } else {
            let recipe = Recipe(name: name, prepTime: prepTime, servingSize: servings, cookTime: cookTime, recipeImageData: nil)
        RecipeController.shared.addRecipeToCloudKit(recipe: recipe, ingredients: ingredients, instructions: instructions)
        }
    }
    @IBAction func addPhotoButtonTapped(_ sender: UIButton) {
        addPhotoActionSheet()
    }
    
    // MARK: - Action Sheet Controller
    
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
        //Hide any keyboards that maybe open
        recipeNameTextField.resignFirstResponder()
        servingsTextField.resignFirstResponder()
        prepTimeTextField.resignFirstResponder()
        instructionTextField.resignFirstResponder()
        ingredientTextField.resignFirstResponder()
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func cameraButton() {
        //Hide any keyboards that maybe open
        recipeNameTextField.resignFirstResponder()
        servingsTextField.resignFirstResponder()
        prepTimeTextField.resignFirstResponder()
        instructionTextField.resignFirstResponder()
        ingredientTextField.resignFirstResponder()
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.sourceType = .camera
        
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
        
    }

    

    
}
