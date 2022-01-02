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

    private var exerciseCategoryColors: [Color]

    var rows: [GridItem] {
        [GridItem()]
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
            VStack(alignment: .leading) {
                HStack {
                    Text(workout.workoutName)

                    LazyHGrid(rows: rows) {
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
