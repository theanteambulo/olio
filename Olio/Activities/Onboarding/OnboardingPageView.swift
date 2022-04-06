//
//  OnboardingPageView.swift
//  Olio
//
//  Created by Jake King on 06/04/2022.
//

import SwiftUI

struct OnboardingPageView: View {
    static let olioTag: String? = "olio"
    static let exercisesTag: String? = "exercises"
    static let templatesTag: String? = "templates"
    static let notificationsTag: String? = "notifications"
    static let historyTag: String? = "history"
    static let communityTag: String? = "community"

    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let imageName: String
    let imageColor: Color
    let buttonEnabled: Bool
    let dismissEnabled: Bool
    @Binding var showingOnboardingJourney: Bool
    @Binding var selectedPage: String?
    @State private var showingSignInWithAppleSheet = false
    @State private var notificationsEnabled = false

    @EnvironmentObject var dataController: DataController

    var body: some View {
        VStack {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 125, height: 125)
                .foregroundColor(imageColor)
                .padding()

            Text(title)
                .font(.largeTitle.bold())
                .padding(.bottom, 5)

            Text(subtitle)
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.bottom, 25)
                .padding(.horizontal)

            Button {
                if buttonEnabled && !dismissEnabled {
                    requestNotifications()
                } else {
                    showingSignInWithAppleSheet = true
                }
            } label: {
                if notificationsEnabled {
                    Text(.notificationsEnabled)
                            .frame(width: 250, height: 44)
                            .foregroundColor(.white)
                            .background(Color.green)
                            .clipShape(Capsule())
                            .padding(.vertical, 5)
                } else {
                    Text(buttonEnabled && !dismissEnabled ? .enableNotifications : .signIn)
                        .frame(width: 250, height: 44)
                        .foregroundColor(buttonEnabled ? .white : .clear)
                        .background(buttonEnabled ? Color.blue : .clear)
                        .clipShape(Capsule())
                        .padding(.vertical, 5)
                }
            }
            .sheet(isPresented: $showingSignInWithAppleSheet, content: SignInView.init)
            .disabled(!buttonEnabled)

            Button {
                showingOnboardingJourney = false
            } label: {
                Text(.noThanks)
                    .foregroundColor(dismissEnabled ? .secondary : .clear)
            }
            .disabled(!dismissEnabled)
        }
    }

    func requestNotifications() {
        dataController.requestNotifications { success in
            if success {
                notificationsEnabled = true
                selectedPage = "history"
            } else {
                print("Permission denied.")
            }
        }
    }
}
