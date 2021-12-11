//
//  SequenceExtension.swift
//  Olio
//
//  Created by Jake King on 26/11/2021.
//

import Foundation

extension Sequence {
    /// Sorts generic objects using a specified key path and sorting method.
    /// - Returns: A sorted array of elements of whichever type was specified in the key path.
    func sorted<Value>(by keyPath: KeyPath<Element, Value>,
                       using areInIncreasingOrder: (Value, Value) throws -> Bool) rethrows -> [Element] {
        try self.sorted {
            try areInIncreasingOrder($0[keyPath: keyPath], $1[keyPath: keyPath])
        }
    }

    /// Sorts comparable objects using a specified key path.
    /// - Returns: A sorted array of elements of whichever type was specified in the key path.
    func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>) -> [Element] {
        self.sorted(by: keyPath, using: <)
    }
}
