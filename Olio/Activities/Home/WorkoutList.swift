//
//  WorkoutList.swift
//  Olio
//
//  Created by Jake King on 26/11/2021.
//

import SwiftUI

struct WorkoutList: View {
    let workouts: FetchRequest<Workout>
    let showingScheduledWorkouts: Bool

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
