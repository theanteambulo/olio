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

    enum ConfirmationAlert {
        case complete
        case delete
    }

    @State private var showingAddConfirmationDialog = false
    @State private var showingConfirmationAlert = false
    @State private var confirmationAlertType = ConfirmationAlert.complete

    var workoutDates: [Date] {
        var dates = [Date]()

        if showScheduledWorkouts {
            for workout in workouts.wrappedValue {
                if !dates.contains(Calendar.current.startOfDay(for: workout.workoutDateScheduled)) {
                    dates.append(Calendar.current.startOfDay(for: workout.workoutDateScheduled))
                }
            }
        } else {
            for workout in workouts.wrappedValue {
                if !dates.contains(Calendar.current.startOfDay(for: workout.workoutDateCompleted)) {
                    dates.append(Calendar.current.startOfDay(for: workout.workoutDateCompleted))
                }
            }
        }

        return dates
    }

    var sortedWorkouts: [Workout] {
        return workouts.wrappedValue.sorted { first, second in
            if showScheduledWorkouts {
                if first.workoutDateScheduled < second.workoutDateScheduled {
                    return true
                } else if first.workoutDateScheduled > second.workoutDateScheduled {
                    return false
                }

                return first.workoutName < second.workoutName
            } else {
                if first.workoutDateCompleted < second.workoutDateCompleted {
                    return true
                } else if first.workoutDateCompleted > second.workoutDateCompleted {
                    return false
                }

                return first.workoutName < second.workoutName
            }
        }
    }

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
                if sortedWorkouts.isEmpty {
                    EmptyView()
                } else {
                    ForEach(workoutDates, id: \.self) { date in
                        Section(header: Text(date.formatted(date: .complete, time: .omitted))) {
                            ForEach(filterWorkoutsByDate(date,
                                                         workouts: sortedWorkouts)) { workout in
                                WorkoutRowView(workout: workout)
                                    .swipeActions(edge: .leading) {
                                        Button {
                                            confirmationAlertType = .complete
                                            showingConfirmationAlert = true
                                        } label: {
                                            Label(workout.completed ? "Schedule": "Complete",
                                                  systemImage: workout.completed ? "calendar" : "checkmark")
                                        }
                                        .tint(workout.completed ? .blue : .green)
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            confirmationAlertType = .delete
                                            showingConfirmationAlert = true
                                        } label: {
                                            Label("Delete",
                                                  systemImage: "trash")
                                        }
                                        .tint(.red)
                                    }
                                    .alert(isPresented: $showingConfirmationAlert) {
                                        switch confirmationAlertType {
                                        case .complete:
                                            return Alert(
                                                title: Text(workout.getConfirmationAlertTitle(workout: workout)),
                                                message: Text(workout.getConfirmationAlertMessage(workout: workout)),
                                                dismissButton: .default(Text("OK")) {
                                                    if workout.completed {
                                                        workout.completed = false
                                                    } else {
                                                        workout.completed = true
                                                    }

                                                    print("Workouts: \(workouts.wrappedValue.count)")
                                                }
                                            )
                                        case .delete:
                                            return Alert(
                                                title: Text("Are you sure?"),
                                                // swiftlint:disable:next line_length
                                                message: Text("Deleting a workout cannot be undone and will also delete all sets contained in the workout."),
                                                primaryButton: .destructive(Text("Delete"),
                                                                            action: {
                                                                                dataController.delete(workout)
                                                                                // swiftlint:disable:next line_length
                                                                                print("Workouts: \(workouts.wrappedValue.count)")
                                                                            }),
                                                secondaryButton: .cancel()
                                            )
                                        }
                                    }
                            }
                        }
                    }
                }
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

    func filterWorkoutsByDate(_ date: Date,
                              workouts: [Workout]) -> [Workout] {
        if showScheduledWorkouts {
            return workouts.filter { Calendar.current.startOfDay(for: $0.workoutDateScheduled) == date }
        } else {
            return workouts.filter { Calendar.current.startOfDay(for: $0.workoutDateCompleted) == date }
        }
    }
}

struct WorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsView(showScheduledWorkouts: true)
    }
}
