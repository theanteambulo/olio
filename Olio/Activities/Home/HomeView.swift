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
    @Environment(\.managedObjectContext) var managedObjectContext

    static let tag: String? = "Home"

    @FetchRequest(
        entity: Workout.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Workout.name, ascending: true)],
        predicate: NSPredicate(format: "template = true")
    ) var workoutTemplates: FetchedResults<Workout>

    let unscheduledWorkouts: FetchRequest<Workout>
    let scheduledWorkouts: FetchRequest<Workout>

    init() {
        // Predicates that will be used in multiple fetch request compound predicates.
        let templatePredicate = NSPredicate(format: "template = false")
        let completedPredicate = NSPredicate(format: "completed = false")

        // Fetch all unscheduled workouts.
        let unscheduledRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        let unscheduledPredicate = NSPredicate(format: "dateScheduled = nil")
        unscheduledRequest.predicate = NSCompoundPredicate(type: .and,
                                                           subpredicates: [templatePredicate,
                                                                           completedPredicate,
                                                                           unscheduledPredicate])
        unscheduledRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Workout.name, ascending: true)
        ]

        unscheduledWorkouts = FetchRequest(fetchRequest: unscheduledRequest)

        // Fetch next 10 scheduled workouts.
        let scheduledRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        let scheduledPredicate = NSPredicate(format: "dateScheduled != nil")
        scheduledRequest.predicate = NSCompoundPredicate(type: .and,
                                                         subpredicates: [templatePredicate,
                                                                         completedPredicate,
                                                                         scheduledPredicate])
        scheduledRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Workout.dateScheduled,
                             ascending: true)
        ]
        scheduledRequest.fetchLimit = 10

        scheduledWorkouts = FetchRequest(fetchRequest: scheduledRequest)
    }

    var addSampleDataToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Add Data") {
                withAnimation {
                    dataController.deleteAll()
                    try? dataController.createSampleData()
                }
            }
        }
    }

    var addWorkoutToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                withAnimation {
                    let workout = Workout(context: managedObjectContext)
                    workout.completed = false
                    workout.template = false
                    dataController.save()
                }
            } label: {
                Label("Add Workout", systemImage: "plus")
            }
        }
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
                        title: "Unscheduled Workouts",
                        scheduledWorkouts: unscheduledWorkouts.wrappedValue
                    )

                    ScheduledWorkoutsView(
                        title: "Scheduled Workouts",
                        scheduledWorkouts: scheduledWorkouts.wrappedValue)
                }
            }
            .padding([.bottom, .horizontal])
            .navigationTitle("Home")
            .toolbar {
                addSampleDataToolbarItem
                addWorkoutToolbarItem
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
