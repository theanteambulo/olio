//
//  OnboardingView.swift
//  Olio
//
//  Created by Jake King on 06/04/2022.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var showingOnboardingJourney: Bool
    @SceneStorage("selectedPage") var selectedPage: String?

    var body: some View {
        TabView(selection: $selectedPage) {
            OnboardingPageView(
                title: Strings.olio.localized,
                subtitle: Strings.olioSubtitle.localized,
                imageName: "heart.circle.fill",
                imageColor: .red,
                buttonEnabled: false,
                dismissEnabled: false,
                showingOnboardingJourney: $showingOnboardingJourney,
                selectedPage: $selectedPage
            )
            .tag(OnboardingPageView.olioTag)

            OnboardingPageView(
                title: Strings.exercisesTab.localized,
                subtitle: Strings.exercisesSubtitle.localized,
                imageName: "books.vertical",
                imageColor: .blue,
                buttonEnabled: false,
                dismissEnabled: false,
                showingOnboardingJourney: $showingOnboardingJourney,
                selectedPage: $selectedPage
            )
            .tag(OnboardingPageView.exercisesTag)

            OnboardingPageView(
                title: Strings.workoutTemplates.localized,
                subtitle: Strings.templatesSubtitle.localized,
                imageName: "doc.text.below.ecg",
                imageColor: .green,
                buttonEnabled: false,
                dismissEnabled: false,
                showingOnboardingJourney: $showingOnboardingJourney,
                selectedPage: $selectedPage
            )
            .tag(OnboardingPageView.templatesTag)

            OnboardingPageView(
                title: Strings.notifications.localized,
                subtitle: Strings.notificationsSubtitle.localized,
                imageName: "bell",
                imageColor: .orange,
                buttonEnabled: true,
                dismissEnabled: false,
                showingOnboardingJourney: $showingOnboardingJourney,
                selectedPage: $selectedPage
            )
            .tag(OnboardingPageView.notificationsTag)

            OnboardingPageView(
                title: Strings.historyTab.localized,
                subtitle: Strings.historySubtitle.localized,
                imageName: "list.dash",
                imageColor: .purple,
                buttonEnabled: false,
                dismissEnabled: false,
                showingOnboardingJourney: $showingOnboardingJourney,
                selectedPage: $selectedPage
            )
            .tag(OnboardingPageView.historyTag)

            OnboardingPageView(
                title: Strings.communityTab.localized,
                subtitle: Strings.communitySubtitle.localized,
                imageName: "person.3",
                imageColor: .yellow,
                buttonEnabled: true,
                dismissEnabled: true,
                showingOnboardingJourney: $showingOnboardingJourney,
                selectedPage: $selectedPage
            )
            .tag(OnboardingPageView.communityTag)
        }
        .tabViewStyle(PageTabViewStyle())
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(showingOnboardingJourney: .constant(true))
    }
}
