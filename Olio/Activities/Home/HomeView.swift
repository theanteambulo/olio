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

    let scheduledWorkouts: FetchRequest<Workout>

    @State private var showingAddConfirmationDialog = false

    init() {
        // Fetch next 10 workouts.
        let scheduledRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        let templatePredicate = NSPredicate(format: "template = false")
        let completedPredicate = NSPredicate(format: "completed = false")
        scheduledRequest.predicate = NSCompoundPredicate(type: .and,
                                                         subpredicates: [templatePredicate,
                                                                         completedPredicate])
        scheduledRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Workout.dateScheduled,
                             ascending: true),
            NSSortDescriptor(keyPath: \Workout.name,
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
                showingAddConfirmationDialog = true
            } label: {
                Label("Add", systemImage: "plus")
            }
            .confirmationDialog(
                Text("Select an option"),
                isPresented: $showingAddConfirmationDialog
            ) {
                Button("New workout") {
                    withAnimation {
                        let workout = Workout(context: managedObjectContext)
                        workout.completed = false
                        workout.template = false
                        workout.name = "New Workout"
                        dataController.save()
                    }
                }

                Button("New workout template") {
                    withAnimation {
                        let workout = Workout(context: managedObjectContext)
                        workout.completed = false
                        workout.template = true
                        workout.name = "New Template"
                        dataController.save()
                    }
                }

                Button("Cancel", role: .cancel) {
                    showingAddConfirmationDialog = false
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading) {
                    Section(header: Text("Templates").font(.headline)) {
                        TemplateWorkoutsView(templateWorkouts: workoutTemplates)
                    }
                    .padding(.top)

                    Text("Scheduled Workouts")
                        .font(.headline)
                }

                List {
                    WorkoutList(workouts: scheduledWorkouts,
                    showingScheduledWorkouts: true)
                }
                .listStyle(InsetGroupedListStyle())
            }
            .padding([.bottom])
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
