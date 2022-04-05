//
//  CloudError.swift
//  Olio
//
//  Created by Jake King on 05/04/2022.
//

import SwiftUI

struct CloudError: Identifiable, ExpressibleByStringInterpolation {
    var id: String { message }
    var message: String

    var localizedMessage: LocalizedStringKey {
        LocalizedStringKey(message)
    }

    init(stringLiteral value: String) {
        self.message = value
    }
}
