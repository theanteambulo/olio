//
//  WorkoutRowView.swift
//  Olio
//
//  Created by Jake King on 25/11/2021.
//

import SwiftUI

/// A single row in a list of workouts representing a given workout.
struct WorkoutRowView: View {
    /// The workout used to construct this view.
    @ObservedObject var workout: Workout

    init(workout: Workout) {
        self.workout = workout
    }

    var upcomingWorkoutLabel: some View {
        let workoutDate = Calendar.current.startOfDay(for: workout.workoutDate)
        let today = Calendar.current.startOfDay(for: .now)
        let tomorrow = Calendar.current.startOfDay(for: .now.addingTimeInterval(86400))

        return Group {
            if workoutDate == today {
                Text(.today)
                    .foregroundColor(.green)
            } else if workoutDate == tomorrow {
                Text(.tomorrow)
                    .foregroundColor(.orange)
            } else {
                Text("")
            }
        }
        .font(.body.bold())
        .textCase(.uppercase)
    }

    var body: some View {
        NavigationLink(destination: EditWorkoutView(workout: workout)) {
            VStack(alignment: .leading, spacing: 3) {
                Text(workout.workoutName)
                    .font(.headline)

                WorkoutExerciseCategoriesLabelView(workout: workout)

                HStack {
                    VStack(alignment: .leading) {
                        Text("\(workout.workoutExercises.count) exercises")
                            .font(.caption)

                        Text("\(workout.workoutExerciseSets.count) sets")
                            .font(.caption)
                    }

                    Spacer()

                    upcomingWorkoutLabel
                }
                .foregroundColor(.secondary)
            }
            .padding(.vertical, 5)
            .accessibilityElement(children: .ignore)
            .accessibilityIdentifier(workout.workoutName)
        }
    }
}

struct WorkoutRowView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutRowView(workout: Workout.example)
    }
}
