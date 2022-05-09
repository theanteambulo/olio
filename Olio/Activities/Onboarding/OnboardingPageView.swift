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
    @State var subtitle: LocalizedStringKey
    let imageName: String
    let imageColor: Color
    @State var buttonEnabled: Bool
    let buttonType: ButtonType?
    let dismissEnabled: Bool
    @Binding var showingOnboardingJourney: Bool
    @Binding var selectedPage: String?
    @State private var showingSignInWithAppleSheet = false
    @State private var notificationsEnabled = false
    @State private var exercisesDownloaded = false

    @EnvironmentObject var dataController: DataController

    var buttonCopy: LocalizedStringKey {
        switch buttonType {
        case .exercises:
            return exercisesDownloaded ? Strings.exercisesDownloaded.localized : Strings.loadOlioExercises.localized
        case .notifications:
            return Strings.enableNotifications.localized
        case .community:
            return Strings.signIn.localized
        default:
            return ""
        }
    }

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
                switch buttonType {
                case .exercises:
                    subtitle = Strings.exercisesDownloadedSubtitle.localized

                    withAnimation {
                        dataController.loadExerciseLibrary()
                        exercisesDownloaded = true
                    }
                case .notifications:
                    withAnimation {
                        requestNotifications()
                    }
                default:
                    showingSignInWithAppleSheet = true
                }

                buttonEnabled = false
            } label: {
                if notificationsEnabled {
                    Text(.notificationsEnabled)
                        .conditionTrueCapsuleButton()
                } else if exercisesDownloaded {
                    Text(.exercisesDownloaded)
                        .conditionTrueCapsuleButton()
                } else if buttonEnabled {
                    Text(buttonCopy)
                        .defaultCapsuleButton()
                } else {
                    Text(buttonCopy)
                        .hiddenCapsuleButton()
                }
            }
            .sheet(isPresented: $showingSignInWithAppleSheet) {
                SignInView(showingOnboardingJourney: $showingOnboardingJourney)
            }
            .disabled(!buttonEnabled)

            Button {
                withAnimation {
                    showingOnboardingJourney = false
                }
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
                withAnimation {
                    selectedPage = "history"
                }
            } else {
                print("Permission denied.")
            }
        }
    }
}
