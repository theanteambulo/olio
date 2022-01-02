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

    var body: some View {
        NavigationLink(destination: EditWorkoutView(workout: workout)) {
            VStack(alignment: .leading) {
                HStack {
                    Text(workout.workoutName)

                    CategoryColorView(colors: workout.getWorkoutColors())
                }

                Text("\(workout.workoutExercises.count) exercises")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("\(workout.workoutExerciseSets.count) sets")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .accessibilityIdentifier(workout.workoutName)
    }
}

struct WorkoutRowView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutRowView(workout: Workout.example)
    }
}
