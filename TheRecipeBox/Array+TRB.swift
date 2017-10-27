//
//  Array+TRB.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 10/26/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        return result
    }
}
