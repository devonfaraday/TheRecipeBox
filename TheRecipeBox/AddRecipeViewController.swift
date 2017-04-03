//
//  AddRecipeViewController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/14/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit
import CloudKit

class AddRecipeViewController: UIViewController, UITableViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recipeImageView.layer.masksToBounds = true
        
        self.tableView.estimatedRowHeight = 40
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    var ingredients = [Ingredient]()
    var instructions = [Instruction]()
    
    var recipe: Recipe?   {
        didSet {
            if !isViewLoaded {
                loadViewIfNeeded()
            }
            updateViews()
        }
    }
    // MARK: - Properties
    let sections = ["Ingredients", "Instructions"]
    
    @IBOutlet weak var addInstructionButton: UIButton!
    @IBOutlet weak var addIngredientButton: UIButton!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeNameTextField: UITextField!
    @IBOutlet weak var prepTimeTextField: UITextField!
    @IBOutlet weak var servingsTextField: UITextField!
    @IBOutlet weak var cookTimeTextField: UITextField!
    @IBOutlet weak var ingredientTextField: UITextField!
    @IBOutlet weak var instructionTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addPhotoButton: UIButton!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
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
        cell.textLabel?.numberOfLines = 0
        if indexPath.section == 0 {
            let ingredient = ingredients[indexPath.row]
            cell.textLabel?.text = ingredient.nameAndAmount
            
        } else {
            let instruction = instructions[indexPath.row]
            cell.textLabel?.text = "\(indexPath.row + 1):  \(instruction.instruction)"
            
        }
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if recipe == nil && !ingredients.isEmpty && editingStyle == .delete  {
                let ingredient = ingredients[indexPath.row]
                
                guard let ingredientIndex = ingredients.index(of: ingredient)
                    else { return }
                ingredients.remove(at: ingredientIndex)
                print("Removing \(ingredient) from index \(ingredientIndex)")
            }
         }
        if indexPath.section == 1 {
            if recipe == nil && !instructions.isEmpty && editingStyle == .delete {
                
                let instruction = instructions[indexPath.row]
                
                guard let instructionIndex = instructions.index(of: instruction) else { return }
                print("Removing \(instruction) from index \(instructionIndex)")
                instructions.remove(at: instructionIndex)
            }
        }
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if recipe == nil {
            return .delete
        } else {
            return .none
        }
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
    
    // MARK: - Text Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - UI Functions
    
    
    @IBAction func addIngredientButtonTapped(_ sender: Any) {
        guard let ingredient = ingredientTextField.text else { return }
        let newIngredient = Ingredient(nameAndAmount: ingredient)
        ingredients.append(newIngredient)
        ingredientTextField.text = ""
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    @IBAction func addInstructionButtonTapped(_ sender: Any) {
        guard let instruction = instructionTextField.text else { return }
        let newInstruction = Instruction(instruction: instruction)
        instructions.append(newInstruction)
        instructionTextField.text = ""
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let name = recipeNameTextField.text,
            let prepTime = prepTimeTextField.text,
            let servings = servingsTextField.text,
            let cookTime = cookTimeTextField.text
            else { return }
        if let image = recipeImageView.image {
            let imageData = UIImageJPEGRepresentation(image, 1.0)
            let recipe = Recipe(name: name, prepTime: prepTime, servingSize: servings, cookTime: cookTime, recipeImageData: imageData)
            
            RecipeController.shared.addRecipeToCloudKit(recipe: recipe, ingredients: ingredients, instructions: instructions, completion: { (error) in
                if let error = error {
                    NSLog("\(error.localizedDescription)\nProblem saving recipe with photo")
                }
            })
        } else {
            let recipe = Recipe(name: name, prepTime: prepTime, servingSize: servings, cookTime: cookTime, recipeImageData: nil)
            
            RecipeController.shared.addRecipeToCloudKit(recipe: recipe, ingredients: ingredients, instructions: instructions, completion: { (error) in
                if let error = error {
                    NSLog("\(error.localizedDescription)\nProblem saving recipe without photo")
                }
            })
        }
        _ = navigationController?.popViewController(animated: true)
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
    
    // MARK: - Helper Functions
    
    func updateViews() {
        guard let recipe = recipe else { return }
        recipeNameTextField.text = recipe.name
        prepTimeTextField.text = recipe.prepTime
        servingsTextField.text = recipe.servingSize
        cookTimeTextField.text = recipe.cookTime
        recipeImageView.image = recipe.recipeImage
        addPhotoButton.setTitle("", for: .normal)
        instructionTextField.isHidden = true
        ingredientTextField.isHidden = true
        addInstructionButton.isHidden = true
        addIngredientButton.isHidden = true
        RecipeController.shared.fetchIngredientsFor(recipe: recipe) { (ingredients) in
            self.ingredients = ingredients
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        RecipeController.shared.fetchInstructionsFor(recipe: recipe) { (instructions) in
            self.instructions = instructions
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        let tableViewTopContraint = NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: servingsTextField, attribute: .bottom, multiplier: 1.0, constant: 8.0)
        let servingSizeHeight = NSLayoutConstraint(item: servingsTextField, attribute: .height, relatedBy: .equal, toItem: prepTimeTextField, attribute: .height, multiplier: 1.0, constant: 0)
        let servingSizeTopConstraint = NSLayoutConstraint(item: servingsTextField, attribute: .top, relatedBy: .equal, toItem: prepTimeTextField, attribute: .top, multiplier: 1.0, constant: 0)
        view.addConstraints([tableViewTopContraint, servingSizeHeight, servingSizeTopConstraint])
        
    }
    
    func updateIngredients() {
        guard let recipe = recipe else { return }
        ingredients = recipe.ingredients
    }
    
    func updateInstructions() {
        guard let recipe = recipe else { return }
        instructions = recipe.instructions
    }
    
}
