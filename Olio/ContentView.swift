//
//  ContentView.swift
//  Olio
//
//  Created by Jake King on 22/11/2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            HistoryView(showCompletedWorkouts: true)
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("History")
                }

            HistoryView(showCompletedWorkouts: false)
                .tabItem {
                    Image(systemName: "books.vertical")
                    Text("Exercises")
                }
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
