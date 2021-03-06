//
//  SignInView.swift
//  Olio
//
//  Created by Jake King on 01/04/2022.
//

import AuthenticationServices
import SwiftUI

enum SignInStatus {
    case unknown
    case authorised
    case failure(Error?)
}

struct SignInView: View {
    @Binding var showingOnboardingJourney: Bool
    @State private var signInStatus = SignInStatus.unknown

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            Group {
                switch signInStatus {
                case .unknown:
                    VStack(alignment: .leading) {
                        ScrollView {
                            Text(.communitySafetyMessage)
                        }

                        Spacer()

                        SignInWithAppleButton(onRequest: configureSignIn,
                                              onCompletion: completeSignIn)
                            .frame(height: 44)
                            .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)

                        Button(Strings.cancelButton.localized, action: closeView)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                case .authorised:
                    Text(.allSet)
                case .failure(let error):
                    if let error = error {
                        Text("\(error.localizedDescription)")
                    }

                    Text(.oopsError)
                }
            }
            .padding()
            .navigationTitle(Strings.signIn.localized)
        }
    }

    func configureSignIn(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName]
    }

    func completeSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let appleID = auth.credential as? ASAuthorizationAppleIDCredential {
                if let fullName = appleID.fullName {
                    let formatter = PersonNameComponentsFormatter()
                    var username = formatter.string(from: fullName).trimmingCharacters(in: .whitespacesAndNewlines)

                    if username.isEmpty {
                        username = "User-\(Int.random(in: 1001..<9999))"
                    }

                    UserDefaults.standard.set(username, forKey: "username")
                    NSUbiquitousKeyValueStore.default.set(username, forKey: "username")
                    signInStatus = .authorised
                    closeView()
                    return
                }
            }

            signInStatus = .failure(nil)
        case .failure(let error):
            if let error = error as? ASAuthorizationError {
                if error.errorCode == ASAuthorizationError.canceled.rawValue {
                    signInStatus = .unknown
                }
            }

            signInStatus = .failure(error)
        }
    }

    func closeView() {
        presentationMode.wrappedValue.dismiss()
        showingOnboardingJourney = false
    }
}
