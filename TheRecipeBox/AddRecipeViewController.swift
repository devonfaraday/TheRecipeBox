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
    
    // MARK: - Properties
    var isEditingRecipe = false
    var recipe: Recipe? {
        didSet {
            if !isViewLoaded {
                loadViewIfNeeded()
            }
            updateViews()
        }
    }
    
    var ingredients = [Ingredient]()
    var instructions = [Instruction]()
    
    let sections = ["Ingredients", "Instructions"]
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldStack: UIStackView!
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
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIsRecipeNil()
        checkIfRecipeBelongsToCurrentUser()
        recipeImageView.layer.masksToBounds = true
        self.tableView.estimatedRowHeight = 40
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - Scroll View Function
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Allows for the tableView to take up more of the screen so the user can see more of the ingredients and instructions at once.
        UIView.animate(withDuration: 0.5) {
            
            if self.tableViewTopConstraint.constant <= 8 && self.tableViewTopConstraint.constant >= -self.recipeImageView.frame.height - 100 {
                self.tableViewTopConstraint.constant -= scrollView.contentOffset.y
            }
            
            if self.tableViewTopConstraint.constant > 8  {
                self.tableViewTopConstraint.constant = 8
            }
            
            if self.tableViewTopConstraint.constant < -self.recipeImageView.frame.height - 100 {
                self.tableViewTopConstraint.constant = -self.recipeImageView.frame.height - 100
            }
        }
    }
    
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
            if recipe == nil || isEditingRecipe || !ingredients.isEmpty && editingStyle == .delete  {
                let ingredient = ingredients[indexPath.row]
                
                guard let ingredientIndex = ingredients.index(of: ingredient)
                    else { return }
                IngredientController.shared.delete(ingredient: ingredient, completion: {
                })
                self.ingredients.remove(at: ingredientIndex)
                tableView.deleteRows(at: [indexPath], with: .fade)
                print("Removing \(ingredient) from index \(ingredientIndex)")
            }
        }
        
        if indexPath.section == 1 {
            if recipe == nil || isEditingRecipe || !instructions.isEmpty && editingStyle == .delete {
                
                let instruction = instructions[indexPath.row]
                
                guard let instructionIndex = instructions.index(of: instruction) else { return }
                print("Removing \(instruction) from index \(instructionIndex)")
                InstructionController.shared.delete(instruction: instruction, completion: {
                })
                self.instructions.remove(at: instructionIndex)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
        // if there is a recipe I don't want the user being able to delete the ingredients or instructions.
        if recipe == nil || isEditingRecipe {
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
    
    
    // MARK: - IBActions
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
        var recipeUserID = CKRecordID(recordName: UUID().uuidString)
        var userID = CKRecordID(recordName: UUID().uuidString)
        if let recipeReference = recipe?.userReference?.recordID, let userIdentifier = UserController.shared.currentUser?.userRecordID {
            recipeUserID = recipeReference
            userID = userIdentifier
        }
        if !isEditingRecipe && recipe != nil && recipeUserID == userID {
            setupEditingView()
        } else if recipe != nil && recipeUserID == userID {
            editRecipe()
            setupDetailView()
        } else {
            saveRecipeToCloudKit()
            tabBarController?.selectedIndex = 2
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
        
        // Only if the photo source is available will the option show up in the action sheet
        
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
        hideAllKeyboards()
        pickPhotoSource(sourceType: .photoLibrary)
    }
    
    func cameraButton() {
        hideAllKeyboards()
        pickPhotoSource(sourceType: .camera)
    }

    
    // MARK: - Helper Functions
    func checkIfRecipeBelongsToCurrentUser() {
        guard recipe != nil else { return }
        if let recipeReference = recipe?.userReference?.recordID, let userIdentifier = UserController.shared.currentUser?.userRecordID {
            if recipeReference == userIdentifier {
                saveButton.isEnabled = true
                saveButton.title = "Edit"
            } else {
                saveButton.isEnabled = false
                saveButton.title = ""
            }
        }
    }
    
    func checkIsRecipeNil() {
        if recipe == nil {
            saveButton.title = "Save"
        } else {
            saveButton.title = "Edit"
        }
    }
    
    func saveRecipeToCloudKit() {
        guard let name = recipeNameTextField.text,
            let prepTime = prepTimeTextField.text,
            let servings = servingsTextField.text,
            let cookTime = cookTimeTextField.text
            else { return }
        if let image = recipeImageView.image {
            let newImage = ImageResizer.resizeImage(image: image, targetSize: CGSize(width: 800, height: 800))
            let imageData = UIImageJPEGRepresentation(newImage, 1.0)
            let recipe = Recipe(name: name, prepTime: prepTime, servingSize: servings, cookTime: cookTime, recipeImageData: imageData)
            
            RecipeController.shared.addRecipeToCloudKit(recipe: recipe, ingredients: ingredients, instructions: instructions, completion: { (error) in
                if let error = error {
                    NSLog("\(error.localizedDescription)\nProblem saving recipe with photo")
                }
            })
        } else {
            noRecipePhotoAlert()
        }
    }
    
    func editRecipe() {
        updateIngredients()
        updateInstructions()
        updateRecipeInfo()
        guard let recipe = recipe else { return }
            IngredientController.shared.addIngredient(ingredients: self.ingredients, toRecipe: recipe) {
                print("Ingredients added To Recipe")
                InstructionController.shared.addInstructions(instructions: self.instructions, toRecipe: recipe, completion: {
                    print("Instructions added to recipe")
                    self.reloadTableViewOnMainQueue()
                })
            }
        isEditingRecipe = false
    }
    
    func pickPhotoSource(sourceType: UIImagePickerControllerSourceType) {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.sourceType = sourceType
        
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func hideAllKeyboards() {
        recipeNameTextField.resignFirstResponder()
        servingsTextField.resignFirstResponder()
        prepTimeTextField.resignFirstResponder()
        instructionTextField.resignFirstResponder()
        ingredientTextField.resignFirstResponder()
    }
    
    func setupEditingView() {
        saveButton.title = "Save"
        addPhotoButton.setTitle("", for: .normal)
        instructionTextField.isHidden = false
        ingredientTextField.isHidden = false
        addInstructionButton.isHidden = false
        addIngredientButton.isHidden = false
        recipeNameTextField.isEnabled = true
        servingsTextField.isEnabled = true
        prepTimeTextField.isEnabled = true
        cookTimeTextField.isEnabled = true
        addPhotoButton.isEnabled = true
        isEditingRecipe = true
    }
    
    func setupDetailView() {
        saveButton.title = "Edit"
        addPhotoButton.setTitle("", for: .normal)
        instructionTextField.isHidden = true
        ingredientTextField.isHidden = true
        addInstructionButton.isHidden = true
        addIngredientButton.isHidden = true
        recipeNameTextField.isEnabled = false
        servingsTextField.isEnabled = false
        prepTimeTextField.isEnabled = false
        cookTimeTextField.isEnabled = false
        addPhotoButton.isEnabled = false
        isEditingRecipe = false
    }
    
    func setupRecipe() {
        guard let recipe = recipe else { return }
        recipeNameTextField.text = recipe.name
        prepTimeTextField.text = recipe.prepTime
        servingsTextField.text = recipe.servingSize
        cookTimeTextField.text = recipe.cookTime
        recipeImageView.image = recipe.recipeImage
    }
    
    func setupInstructions(completion: @escaping() -> Void) {
        guard let recipe = recipe else { return }
        RecipeController.shared.fetchInstructionsFor(recipe: recipe) { (instructions) in
            self.instructions = instructions
            completion()
        }
    }
    
    func setupIngredients(completion: @escaping() -> Void) {
        guard let recipe = recipe else { return }
        RecipeController.shared.fetchIngredientsFor(recipe: recipe) { (ingredients) in
            self.ingredients = ingredients
            completion()
        }
    }
    
    func reloadTableViewOnMainQueue() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func updateViews() {
        setupDetailView()
        setupRecipe()
        setupIngredients {
            self.setupInstructions {
                self.reloadTableViewOnMainQueue()
            }
        }
            }
    
    
    
    func updateIngredients() {
        recipe?.ingredients = ingredients
    }
    
    func updateInstructions() {
        recipe?.instructions = instructions
    }

    func updateRecipeInfo() {
        guard let recipe = recipe,
            let name = recipeNameTextField.text,
            let servings = servingsTextField.text,
            let prepTime = prepTimeTextField.text,
            let cookTime = cookTimeTextField.text
        else { return }
        recipe.name = name
        recipe.servingSize = servings
        recipe.prepTime = prepTime
        recipe.cookTime = cookTime
        RecipeController.shared.modify(recipe: recipe) {
            print("Recipe Modified")
        }
        
    }
    // MARK: - Constraints
    
    func constraintsForRecipeDetail() {
        let tableViewTopContraint = NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: servingsTextField, attribute: .bottom, multiplier: 1.0, constant: 8.0)
        let servingSizeHeight = NSLayoutConstraint(item: servingsTextField, attribute: .height, relatedBy: .equal, toItem: prepTimeTextField, attribute: .height, multiplier: 1.0, constant: 0)
        let servingSizeTopConstraint = NSLayoutConstraint(item: servingsTextField, attribute: .top, relatedBy: .equal, toItem: prepTimeTextField, attribute: .top, multiplier: 1.0, constant: 0)
        let cookTimeTopConstraint = NSLayoutConstraint(item: cookTimeTextField, attribute: .top, relatedBy: .equal, toItem: servingsTextField, attribute: .top, multiplier: 1.0, constant: 0)
        let cookTimeHeight = NSLayoutConstraint(item: cookTimeTextField, attribute: .height, relatedBy: .equal, toItem: servingsTextField, attribute: .height, multiplier: 1.0, constant: 0)
        view.addConstraints([tableViewTopContraint, servingSizeHeight, servingSizeTopConstraint, cookTimeTopConstraint, cookTimeHeight])
    }
    
    // MARK: - Alert Controllers
    
    func noRecipePhotoAlert() {
        let alertController = UIAlertController(title: nil, message: "Please add photo", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let uploadAction = UIAlertAction(title: "Upload Photo", style: .default) { (_) in
            self.addPhotoActionSheet()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(uploadAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}

