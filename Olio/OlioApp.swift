//
//  OlioApp.swift
//  Olio
//
//  Created by Jake King on 22/11/2021.
//

import SwiftUI

@main
struct OlioApp: App {
    // App creates and owns the data controller, ensuring it stays alive for the duration of the app's runtime.
    @StateObject var dataController: DataController

    init() {
        let dataController = DataController()
        _dataController = StateObject(wrappedValue: dataController)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Send the data controller's view context into the SwiftUI environment - i.e. connect
                // Core Data to SwiftUI.
                .environment(\.managedObjectContext, dataController.container.viewContext)
                // Send in the data controller to enable manipulation of data elsewhere in code.
                .environmentObject(dataController)
                // Ensure the user's data is saved when the app is moved to the background.
                .onReceive(
                    NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification),
                    perform: save)
        }
    }

    func save(_ note: Notification) {
        dataController.save()
    }
}
