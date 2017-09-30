//
//  Instructions.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 3/13/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class Instruction: Equatable {
    var instruction: String
    var recipeReference: CKReference?
    var index: Int
    var recordID: CKRecordID?
    
    init(instruction: String, index: Int = 0) {
        self.instruction = instruction
        self.index = index
    }
}

extension Instruction {
    convenience init?(cloudKitRecord: CKRecord) {
        guard let instruction = cloudKitRecord[Constants.instructionKey] as? String,
            let index = cloudKitRecord["index"] as? Int  else { return nil }
        self.init(instruction: instruction, index: index)
        self.recipeReference = cloudKitRecord[Constants.recipeReferenceKey] as? CKReference
        self.recordID = cloudKitRecord.recordID
    }
}

extension CKRecord {
    convenience init(instruction: Instruction) {
        let recordID = instruction.recordID ?? CKRecordID(recordName: UUID().uuidString)
        self.init(recordType: Constants.instructionsRecordType, recordID: recordID)
        self.setValue(instruction.instruction, forKey: Constants.instructionKey)
        self.setValue(instruction.recipeReference, forKey: Constants.recipeReferenceKey)
        self.setValue(instruction.index, forKey: "index")
        instruction.recordID = recordID
    }
}

func ==(lhs: Instruction, rhs: Instruction) -> Bool {
    return lhs === rhs
}
