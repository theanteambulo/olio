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

                Text("\(workout.workoutExercises.count) exercises")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("\(workout.workoutExerciseSets.count) sets")
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
