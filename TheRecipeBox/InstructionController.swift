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
    
    // TODO: delete instruction for editing
}
