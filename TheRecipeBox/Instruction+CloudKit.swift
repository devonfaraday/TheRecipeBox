//
//  Instruction+CloudKit.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/13/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

extension Instruction {
    convenience init?(cloudKitRecord: CKRecord) {
        guard let instruction = cloudKitRecord[Constants.instructionKey] as? String,
              let index = cloudKitRecord["index"] as? Int  else { return nil }
        self.init(instruction: instruction, index: index)
        self.recipeReference = cloudKitRecord[Constants.recipeReferenceKey] as? CKReference
    }
}

extension CKRecord {
    convenience init(instruction: Instruction) {
        self.init(recordType: Constants.instructionsRecordType)
        self.setValue(instruction.instruction, forKey: Constants.instructionKey)
        self.setValue(instruction.recipeReference, forKey: Constants.recipeReferenceKey)
        self.setValue(instruction.index, forKey: "index")
    }
}
