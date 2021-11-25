//
//  HomeView.swift
//  Olio
//
//  Created by Jake King on 23/11/2021.
//

import CoreData
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataController: DataController

    static let tag: String? = "Home"

    @FetchRequest(
        entity: Workout.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Workout.name, ascending: true)],
        predicate: NSPredicate(format: "template = true")
    ) var workoutTemplates: FetchedResults<Workout>

    let scheduledWorkouts: FetchRequest<Workout>

    init() {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        let templatePredicate = NSPredicate(format: "template = false")
        let completedPredicate = NSPredicate(format: "completed = false")
        request.predicate = NSCompoundPredicate(type: .and,
                                                subpredicates: [templatePredicate,
                                                                completedPredicate])
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Workout.dateScheduled,
                             ascending: true)
        ]
        request.fetchLimit = 10

        scheduledWorkouts = FetchRequest(fetchRequest: request)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Section(header: Text("Templates").font(.headline)) {
                        TemplateWorkoutsView(templateWorkouts: workoutTemplates)
                    }
                    .padding(.top)

                    ScheduledWorkoutsView(
                        title: "Scheduled Workouts",
                        scheduledWorkouts: scheduledWorkouts.wrappedValue)

                    Button("Add data") {
                        dataController.deleteAll()
                        try? dataController.createSampleData()
                    }
                }
            }
            .background(Color.systemGroupedBackground.ignoresSafeArea())
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
