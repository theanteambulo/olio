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

    /// The array of colors corresponding to unique exercise categories in this workout.
    private var exerciseCategoryColors: [Color]

    /// A grid with a single row.
    var rows: [GridItem] {
        Array(repeating: GridItem(), count: 1)
    }

    init(workout: Workout) {
        self.workout = workout
        exerciseCategoryColors = [Color]()

        for exercise in workout.workoutExercises.sorted(by: \.exerciseCategory) {
            exerciseCategoryColors.append(exercise.getExerciseCategoryColor())
        }

        exerciseCategoryColors.removeDuplicates()
    }

    var body: some View {
        NavigationLink(destination: EditWorkoutView(workout: workout)) {
            VStack(alignment: .leading, spacing: 0) {
                Text(workout.workoutName)

                if !workout.workoutExercises.isEmpty {
                    LazyHGrid(rows: rows, spacing: 7) {
                        ForEach(exerciseCategoryColors, id: \.self) { categoryColor in
                            Circle()
                                .frame(width: 7)
                                .foregroundColor(categoryColor)
                        }
                    }
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
