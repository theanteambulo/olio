//
//  WorkoutRowView.swift
//  Olio
//
//  Created by Jake King on 25/11/2021.
//

import SwiftUI

struct WorkoutRowView: View {
    @ObservedObject var workout: Workout

    var body: some View {
        NavigationLink(destination: EditWorkoutView(workout: workout)) {
            VStack(alignment: .leading) {
                Text(workout.workoutName)
                Text(workout.workoutId)
                    .font(.caption)
                    .foregroundColor(.secondary)
                // swiftlint:disable:next line_length
                Text("\(workout.workoutExercises.count) \(workout.workoutExercises.count == 1 ? "exercise" : "exercises"), \(workout.workoutExerciseSets.count) \(workout.workoutExerciseSets.count == 1 ? "set" : "sets")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct WorkoutRowView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutRowView(workout: Workout.example)
    }
}
