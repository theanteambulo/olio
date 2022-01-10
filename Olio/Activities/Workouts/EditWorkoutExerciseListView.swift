//
//  EditWorkoutExerciseListView.swift
//  Olio
//
//  Created by Jake King on 01/12/2021.
//

import SwiftUI

/// A section to be used in EditWorkoutView containing the "body" of an exercise for a given workout.
///
/// The "body" of an exercise is in essence a list consisting of an instance of ExerciseHeaderView, instances of
/// ExerciseSetView corresponding to the number of exercise sets in the exercise, followed by buttons to add an
/// additional exercise set to the exercise or remove the exercise from the workout.
struct EditWorkoutExerciseListView: View {
    /// The workout used to construct this view.
    @ObservedObject var workout: Workout

    /// The exercise used to construct this view.
    @ObservedObject var exercise: Exercise

    /// The environment singleton responsible for managing the Core Data stack.
    @EnvironmentObject var dataController: DataController

    /// Boolean to indicate whether the sheet showing the exercise's sets is displayed.
    @State private var showingExerciseSheet = false

    var exerciseSetsForWorkout: [ExerciseSet] {
        exercise.exerciseSets.filter({ $0.workout == workout })
    }

    /// The number of sets in the workout for the given exercise.
    var exerciseSetCount: Int {
        exerciseSetsForWorkout.count
    }

    /// The number of completed sets in the workout for the given exercise.
    var completedExerciseSetCount: Int {
        exerciseSetsForWorkout.filter({ $0.completed == true }).count
    }

    /// The percentage of exercise sets completed, expressed as a double.
    var exerciseCompletionAmountDouble: Double {
        guard exerciseSetsForWorkout.isEmpty == false else { return 0 }

        return Double(completedExerciseSetCount) / Double(exerciseSetCount)
    }

    /// The percentage of exercises sets completed, expressed as an integer.
    var exerciseCompletionAmountInt: Int {
        Int(100 * exerciseCompletionAmountDouble)
    }

    var exerciseSetCompletionCountText: Text {
        if exerciseSetCount != 0 {
            return Text(", \(completedExerciseSetCount) completed")
        }

        return Text("")
    }

    var exerciseSetsDescriptionView: some View {
        Group {
            if workout.template {
                Text("\(exerciseSetCount) sets")
            } else {
                Text("\(exerciseSetCount) sets") + exerciseSetCompletionCountText
            }
        }
        .font(.caption)
        .foregroundColor(.secondary)
    }

    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading) {
                // The exercise header showing progress for non-template workouts.
                if !workout.template {
                    ProgressView(value: exerciseCompletionAmountDouble)
                        .tint(exercise.getExerciseCategoryColor())
                        .padding(.top, 5)
                }

                Text(exercise.exerciseName)
                    .font(.headline)

                Text(exercise.exerciseCategory)
                    .font(.caption)
                    .foregroundColor(exercise.getExerciseCategoryColor())

                exerciseSetsDescriptionView
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 5)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(exercise.exerciseName), progress: \(exerciseCompletionAmountInt)%"))
        .onTapGesture {
            showingExerciseSheet = true
        }
        .sheet(isPresented: $showingExerciseSheet) {
            ExerciseSheetView(workout: workout, exercise: exercise)
        }
    }
}

struct EditWorkoutExerciseListView_Previews: PreviewProvider {
    static var previews: some View {
        EditWorkoutExerciseListView(workout: Workout.example, exercise: Exercise.example)
    }
}
