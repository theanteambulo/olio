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

    let scheduledWorkouts: FetchRequest<Workout>

    @State private var showingAddConfirmationDialog = false

    init() {
        // Fetch next 10 workouts.
        let scheduledRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        let completedPredicate = NSPredicate(format: "completed = false")
        scheduledRequest.predicate = NSCompoundPredicate(type: .and,
                                                         subpredicates: [completedPredicate])
        scheduledRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Workout.dateScheduled,
                             ascending: true),
            NSSortDescriptor(keyPath: \Workout.name,
                             ascending: true)
        ]
        scheduledRequest.fetchLimit = 10

        scheduledWorkouts = FetchRequest(fetchRequest: scheduledRequest)
    }

    var deleteAllDataToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Delete Data") {
                dataController.deleteAll()
                dataController.save()
            }
        }
    }

    var countDataToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Count Data") {
                print("Workouts: \(dataController.count(for: Workout.fetchRequest()))")
                print("Exercises: \(dataController.count(for: Exercise.fetchRequest()))")
                print("Exercise Sets: \(dataController.count(for: ExerciseSet.fetchRequest()))")
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
                        workout.id = UUID()
                        workout.completed = false
                        workout.name = "New Workout"
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
            List {
                WorkoutListView(workouts: scheduledWorkouts,
                showingScheduledWorkouts: true)
            }
            .listStyle(InsetGroupedListStyle())
            .padding([.bottom])
            .navigationTitle("Scheduled")
            .toolbar {
                deleteAllDataToolbarItem
                countDataToolbarItem
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
