//
//  LocalizedStringKeyExtension.swift
//  Olio
//
//  Created by Jake King on 29/03/2022.
//

import Foundation
import SwiftUI

extension LocalizedStringKey {
    var stringKey: String {
        let description = "\(self)"
        let components = description.components(separatedBy: "key: \"")
            .map { $0.components(separatedBy: "\",") }

        return components[1][0]
    }

    func stringValue(locale: Locale = .current) -> String {
        return .localizedString(for: self.stringKey, locale: locale)
    }
}
