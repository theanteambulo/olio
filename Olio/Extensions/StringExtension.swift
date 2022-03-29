//
//  StringExtension.swift
//  Olio
//
//  Created by Jake King on 29/03/2022.
//

import Foundation

extension String {
    static func localizedString(for key: String,
                                locale: Locale = .current) -> String {
        let language = locale.languageCode
        let path = Bundle.main.path(forResource: language, ofType: "lproj")!
        let bundle = Bundle(path: path)!
        let localizedString = NSLocalizedString(key, bundle: bundle, comment: "")

        return localizedString
    }
}
