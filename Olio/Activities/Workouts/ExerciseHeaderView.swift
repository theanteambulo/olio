//
//  ExerciseHeaderView.swift
//  Olio
//
//  Created by Jake King on 30/11/2021.
//

import SwiftUI

/// A header for a given exercise in a given workout representing the percentage of exercise sets completed so far.
///
/// Used as component to construct EditWorkoutExerciseListView.
struct ExerciseHeaderView: View {
    /// The workout used to construct this view.
    @ObservedObject var workout: Workout

    /// The exercise used to construct this view.
    @ObservedObject var exercise: Exercise

    /// The percentage of exercises sets completed, expressed as an integer.
    var exerciseCompletionAmountInt: Int {
        Int(100 * exerciseCompletionAmount(exercise))
    }

    /// A count of the exercise sets for this exercise in this workout.
    var exerciseSetsAll: [ExerciseSet] {
        exercise.exerciseSets.filter { $0.workout == workout }
    }

    /// A count of the exercise sets completed, expressed as an integer.
    var exerciseSetsCompleted: [ExerciseSet] {
        return exerciseSetsAll.filter { $0.completed == true }
    }

    var body: some View {
        HStack {
            Text("\(exerciseSetsCompleted.count) / \(exerciseSetsAll.count)")
                .frame(minWidth: 50, alignment: .leading)

            ProgressView(value: exerciseCompletionAmount(exercise))
                .tint(exercise.getExerciseCategoryColor())
                .frame(minWidth: 220)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Progress: \(exerciseCompletionAmountInt)%"))
    }

    /// Calculates the percentage of exercise sets completed for a given exercise.
    ///
    /// Note a Double is returned as ProgressView requires a BinaryFloatingPoint type.
    /// - Parameter exercise: The exercise parent to the exercise sets.
    /// - Returns: A Double representing the percentage of exercises sets completed.
    func exerciseCompletionAmount(_ exercise: Exercise) -> Double {
        let allSets = exercise.exerciseSets.filter { $0.workout == workout }
        guard allSets.isEmpty == false else { return 0 }

        let completedSets = allSets.filter { $0.completed == true }

        return Double(completedSets.count) / Double(allSets.count)
    }
}

struct ExerciseHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseHeaderView(workout: Workout.example, exercise: Exercise.example)
    }
}
