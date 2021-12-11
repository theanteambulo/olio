//
//  BindingExtension.swift
//  Olio
//
//  Created by Jake King on 24/11/2021.
//

import SwiftUI

extension Binding {
    /// Calls a handler method when a binding's value is changed.
    /// - Parameter handler: The method to call on change of the binding's value.
    /// - Returns: A new instance of Binding that uses the same type of data as the original binding.
    func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler()
            }
        )
    }
}
