//
//  ViewExtension.swift
//  Olio
//
//  Created by Jake King on 25/11/2021.
//

import Foundation
import SwiftUI

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
}
