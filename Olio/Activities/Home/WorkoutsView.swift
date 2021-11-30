//
//  WorkoutsView.swift
//  Olio
//
//  Created by Jake King on 30/11/2021.
//

import CoreData
import SwiftUI

struct WorkoutsView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var managedObjectContext

    static let scheduledTag: String? = "Scheduled"
    static let historyTag: String? = "History"

    let workouts: FetchRequest<Workout>
    let showScheduledWorkouts: Bool

    @State private var showingAddConfirmationDialog = false

    init(showScheduledWorkouts: Bool) {
        self.showScheduledWorkouts = showScheduledWorkouts

        let workoutsRequest: NSFetchRequest<Workout> = Workout.fetchRequest()

        if showScheduledWorkouts {
            // Fetch top 10 scheduled workouts (i.e. not completed).
            let completedPredicate = NSPredicate(format: "completed = false")
            workoutsRequest.predicate = NSCompoundPredicate(type: .and,
                                                            subpredicates: [completedPredicate])
            workoutsRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \Workout.dateScheduled,
                                 ascending: true),
                NSSortDescriptor(keyPath: \Workout.name,
                                 ascending: true)
            ]

            workoutsRequest.fetchLimit = 10
        } else {
            // Fetch all completed workouts.
            let completedPredicate = NSPredicate(format: "completed = true")
            workoutsRequest.predicate = NSCompoundPredicate(type: .and,
                                                            subpredicates: [completedPredicate])
            workoutsRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \Workout.dateCompleted,
                                 ascending: true),
                NSSortDescriptor(keyPath: \Workout.name,
                                 ascending: true)
            ]
        }

        workouts = FetchRequest(fetchRequest: workoutsRequest)
    }

    var deleteAllDataToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            if showScheduledWorkouts {
                Button("Delete Data") {
                    dataController.deleteAll()
                    dataController.save()
                }
            }
        }
    }

    var countDataToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            if showScheduledWorkouts {
                Button("Count Data") {
                    print("Workouts: \(dataController.count(for: Workout.fetchRequest()))")
                    print("Exercises: \(dataController.count(for: Exercise.fetchRequest()))")
                    print("Exercise Sets: \(dataController.count(for: ExerciseSet.fetchRequest()))")
                }
            }
        }
    }

    var addWorkoutToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if showScheduledWorkouts {
                Button {
                    showingAddConfirmationDialog = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
                .confirmationDialog(Text("Select an option"),
                                    isPresented: $showingAddConfirmationDialog) {
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
    }

    var body: some View {
        NavigationView {
            List {
                WorkoutListView(workouts: workouts,
                                showingScheduledWorkouts: showScheduledWorkouts)
            }
            .listStyle(InsetGroupedListStyle())
            .padding(.bottom)
            .navigationTitle(showScheduledWorkouts
                             ? "Scheduled"
                             : "History")
            .toolbar {
                deleteAllDataToolbarItem
                countDataToolbarItem
                addWorkoutToolbarItem
            }
        }
    }
}

struct WorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsView(showScheduledWorkouts: true)
    }
}
