//
//  InstructionController.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 8/14/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class InstructionController {
    
    static let shared = InstructionController()
    
    func addInstructions(instructions: [Instruction], toRecipe recipe: Recipe, completion: @escaping() -> Void) {
        
        // get the recipe recordID
        guard let recipeID = recipe.recordID else { return }
        let recipeReference = CKReference(recordID: recipeID, action: .deleteSelf)
        // save instuctions with recipeID as it's parent
        for instruction in instructions {
            instruction.recipeReference = recipeReference
            CloudKitManager.shared.publicDatabase.save(CKRecord(instruction: instruction), completionHandler: { (_, error) in
                if let error = error  {
                    NSLog("Error saving instrucion \(instruction.instruction) to recipe \(recipe.name):\n\(error.localizedDescription)")
                    
                }
                
                completion()
            })
    }
}
    // Modifies instruction
    func modify(instruction: Instruction, completion: @escaping() -> Void) {
        let cloudKitManager = CloudKitManager()
        let record = CKRecord(instruction: instruction)
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        cloudKitManager.publicDatabase.add(operation)
        completion()
    }
    // Delete instruction for editing
    
    func delete(instruction: Instruction, completion: @escaping() -> Void) {
        guard let recordID = instruction.recordID else { return }
        
        CloudKitManager.shared.publicDatabase.delete(withRecordID: recordID) { (_, error) in
            if let error = error {
                NSLog("Could not delete instruction \(instruction.instruction):\n\(error.localizedDescription)")
            }
            completion()
                
        }
    }
}
