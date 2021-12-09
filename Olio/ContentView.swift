//
//  ContentView.swift
//  Olio
//
//  Created by Jake King on 22/11/2021.
//

import SwiftUI

struct ContentView: View {
    @SceneStorage("selectedView") var selectedView: String?
    @EnvironmentObject var dataController: DataController

    var body: some View {
        TabView(selection: $selectedView) {
            WorkoutsView(dataController: dataController,
                         showingCompletedWorkouts: false)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(WorkoutsView.scheduledTag)
                .phoneOnlyStackNavigationView()

            WorkoutsView(dataController: dataController,
                         showingCompletedWorkouts: true)
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("History")
                }
                .tag(WorkoutsView.historyTag)
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
