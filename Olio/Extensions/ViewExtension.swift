//
//  ViewExtension.swift
//  Olio
//
//  Created by Jake King on 25/11/2021.
//

import Foundation
import SwiftUI

/// A style for TextField where the input could be a decimal.
struct ExerciseSetDecimalTextField: ViewModifier {
    /// Styles content according to the modifiers applied.
    /// - Parameter content: Content to modify.
    /// - Returns: Modified content as a View.
    func body(content: Content) -> some View {
        content
            .frame(width: 75)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.decimalPad)
    }
}

/// A style for TextField where the input is an integer.
struct ExerciseSetIntegerTextField: ViewModifier {
    /// Styles content according to the modifiers applied.
    /// - Parameter content: Content to modify.
    /// - Returns: Modified content as a View.
    func body(content: Content) -> some View {
        content
            .frame(width: 75)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.numberPad)
    }
}

extension View {
    /// Ensures that the navigation view style used by the app is stacked when the user's device is a phone.
    /// - Returns: The view with the navigationViewStyle() modifier applied.
    func phoneOnlyStackNavigationView() -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return AnyView(self.navigationViewStyle(StackNavigationViewStyle()))
        } else {
            return AnyView(self)
        }
    }

    /// Styles TextField for use in in ExerciseSetView.
    ///
    /// Use where TextField could take decimal input.
    /// - Returns: The styled TextField.
    func exerciseSetDecimalTextField() -> some View {
        modifier(ExerciseSetDecimalTextField())
    }

    /// Styles TextField for use in in ExerciseSetView.
    ///
    /// Use where TextField requires integer input.
    /// - Returns: The styled TextField.
    func exerciseSetIntegerTextField() -> some View {
        modifier(ExerciseSetIntegerTextField())
    }

    /// Force hides any keyboard currently being displayed.
    #if canImport(UIKit)
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil,
                                        from: nil,
                                        for: nil)
    }
    #endif
}
