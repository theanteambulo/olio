//
//  ScheduledWorkoutsView.swift
//  Olio
//
//  Created by Jake King on 30/11/2021.
//

import CoreData
import SwiftUI

struct ScheduledWorkoutsView: View {
    let workouts: FetchRequest<Workout>

    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var managedObjectContext

    static let scheduledTag: String? = "Scheduled"

    @State private var showingAddConfirmationDialog = false

    var sortedWorkouts: [Workout] {
        return workouts.wrappedValue.sorted { first, second in
            if first.workoutDate < second.workoutDate {
                return true
            } else if first.workoutDate > second.workoutDate {
                return false
            }

            return first.workoutName < second.workoutName
        }
    }

    init() {
        let workoutsRequest: NSFetchRequest<Workout> = Workout.fetchRequest()

        let completedPredicate = NSPredicate(format: "completed = false")
        workoutsRequest.predicate = NSCompoundPredicate(type: .and,
                                                        subpredicates: [completedPredicate])
        workoutsRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Workout.date,
                             ascending: true),
            NSSortDescriptor(keyPath: \Workout.name,
                             ascending: true)
        ]

        workoutsRequest.fetchLimit = 10

        workouts = FetchRequest(fetchRequest: workoutsRequest)
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
            .confirmationDialog(Text("Select an option"),
                                isPresented: $showingAddConfirmationDialog) {
                Button("New workout") {
                    withAnimation {
                        let workout = Workout(context: managedObjectContext)
                        workout.id = UUID()
                        workout.date = Date()
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
            WorkoutsListView(workouts: sortedWorkouts)
                .padding(.bottom)
                .navigationTitle("Scheduled")
                .toolbar {
                    deleteAllDataToolbarItem
                    countDataToolbarItem
                    addWorkoutToolbarItem
                }
        }
    }
}

struct ScheduledWorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduledWorkoutsView()
    }
}
