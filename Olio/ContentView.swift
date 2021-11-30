//
//  ContentView.swift
//  Olio
//
//  Created by Jake King on 22/11/2021.
//

import SwiftUI

struct ContentView: View {
    @SceneStorage("selectedView") var selectedView: String?

    var body: some View {
        TabView(selection: $selectedView) {
            WorkoutsView(showScheduledWorkouts: true)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(WorkoutsView.scheduledTag)
                .phoneOnlyStackNavigationView()

            WorkoutsView(showScheduledWorkouts: false)
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("History")
                }
                .tag(WorkoutsView.scheduledTag)
                .phoneOnlyStackNavigationView()

            ExercisesView()
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
