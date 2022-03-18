//
//  ContentView.swift
//  Olio
//
//  Created by Jake King on 22/11/2021.
//

import CoreSpotlight
import SwiftUI

struct ContentView: View {
    /// The current screen displayed, stored for state restoration.
    @SceneStorage("selectedView") var selectedView: String?
    /// The environment singleton responsible for managing the Core Data stack.
    @EnvironmentObject var dataController: DataController

    var body: some View {
        TabView(selection: $selectedView) {
            // "Home" tab - displays templates and scheduled workouts.
            HomeView(dataController: dataController, showingCompletedWorkouts: false)
                .tabItem {
                    Image(systemName: "house")
                    Text(.homeTab)
                }
                .tag(HomeView.homeTag)
                .phoneOnlyStackNavigationView()

            // "History" tab - displays completed workouts.
            HomeView(dataController: dataController, showingCompletedWorkouts: true)
                .tabItem {
                    Image(systemName: "list.dash")
                    Text(.historyTab)
                }
                .tag(HomeView.historyTag)
                .phoneOnlyStackNavigationView()

            // "Exercises" tab - displays library of added exercises.
            ExercisesView(dataController: dataController)
                .tabItem {
                    Image(systemName: "books.vertical")
                    Text(.exercisesTab)
                }
                .tag(ExercisesView.tag)
                .phoneOnlyStackNavigationView()
        }
        .onContinueUserActivity(CSSearchableItemActionType, perform: moveToHome)
        .onOpenURL(perform: openURL)
    }

    func moveToHome(_ input: Any) {
        selectedView = HomeView.homeTag
    }

    func openURL(url: URL) {
        selectedView = HomeView.homeTag
        dataController.createNewWorkoutOrTemplate(isTemplate: false,
                                                  daysOffset: 0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
