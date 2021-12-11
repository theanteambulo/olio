//
//  ContentView.swift
//  Olio
//
//  Created by Jake King on 22/11/2021.
//

import SwiftUI

struct ContentView: View {
    /// The current screen displayed, stored for state restoration.
    @SceneStorage("selectedView") var selectedView: String?
    /// The environment singleton responsible for managing the Core Data stack.
    @EnvironmentObject var dataController: DataController

    var body: some View {
        TabView(selection: $selectedView) {
            // "Home" tab - displays templates and scheduled workouts.
            WorkoutsView(dataController: dataController,
                         showingCompletedWorkouts: false)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(WorkoutsView.homeTag)
                .phoneOnlyStackNavigationView()

            // "History" tab - displays completed workouts.
            WorkoutsView(dataController: dataController,
                         showingCompletedWorkouts: true)
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("History")
                }
                .tag(WorkoutsView.historyTag)
                .phoneOnlyStackNavigationView()

            // "Exercises" tab - displays library of added exercises.
            ExercisesView(dataController: dataController)
                .tabItem {
                    Image(systemName: "books.vertical")
                    Text("Exercises")
                }
                .tag(ExercisesView.tag)
                .phoneOnlyStackNavigationView()
        }
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
