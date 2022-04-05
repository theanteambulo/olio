//
//  ErrorCloudKitMessages.swift
//  Olio
//
//  Created by Jake King on 05/04/2022.
//

import CloudKit
import Foundation

extension Error {
    func getCloudKitError() -> CloudError {
        guard let error = self as? CKError else {
            return "An unknown error occurred: \(self.localizedDescription)"
        }

        switch error.code {
        // These should never happen in production
        case .badContainer, .badDatabase, .invalidArguments:
            return "A fatal error occurred: \(error.localizedDescription)"
        // A connection couldn't be made, the user's network is down, connection was too weak to use, or iCloud is down
        case .networkFailure, .networkUnavailable, .serverResponseLost, .serviceUnavailable:
            return "There was a problem communicating with iCloud; please check your network connection and try again."
        case .notAuthenticated:
            return "There was a problem with your iCloud account; please check you are logged into iCloud."
        case .requestRateLimited:
            return "You've hit iCloud's rate limit; please wait a moment then try again."
        case .quotaExceeded:
            return "You've exceeded your iCloud quota; please clear up some space and try again."
        default:
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}
