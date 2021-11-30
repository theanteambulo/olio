//
//  WorkoutListView.swift
//  Olio
//
//  Created by Jake King on 29/11/2021.
//

import SwiftUI

struct WorkoutListView: View {
    let workouts: FetchRequest<Workout>
    let showingScheduledWorkouts: Bool

    @EnvironmentObject var dataController: DataController

    enum ConfirmationAlert {
        case complete
        case delete
    }

    @State private var showingConfirmationAlert = false
    @State private var confirmationAlertType = ConfirmationAlert.complete

    var workoutDates: [Date] {
        var dates = [Date]()

        if showingScheduledWorkouts {
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
            if showingScheduledWorkouts {
                if first.workoutDateScheduled < second.workoutDateScheduled {
                    return true
                } else {
                    return false
                }
            } else {
                if first.workoutDateCompleted < second.workoutDateCompleted {
                    return true
                } else {
                    return false
                }
            }
        }
    }

    var body: some View {
        if sortedWorkouts.isEmpty {
            EmptyView()
        } else {
            ForEach(workoutDates, id: \.self) { date in
                Section(header: Text(date.formatted(date: .complete, time: .omitted))) {
                    ForEach(filterWorkoutsByDate(date, workouts: sortedWorkouts)) { workout in
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

    func filterWorkoutsByDate(_ date: Date,
                              workouts: [Workout]) -> [Workout] {
        if showingScheduledWorkouts {
            return workouts.filter { Calendar.current.startOfDay(for: $0.workoutDateScheduled) == date}
        } else {
            return workouts.filter { Calendar.current.startOfDay(for: $0.workoutDateCompleted) == date}
        }
    }
}
