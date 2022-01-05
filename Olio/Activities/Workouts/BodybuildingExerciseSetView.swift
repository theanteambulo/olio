//
//  BodybuildingExerciseSetView.swift
//  Olio
//
//  Created by Jake King on 04/01/2022.
//

import SwiftUI

/// A single row for a weighted or bodyweight exercise in a workout representing a set added to that exercise.
struct BodybuildingExerciseSetView: View {
    /// The exercise set used to construct this view.
    @ObservedObject var exerciseSet: ExerciseSet

    /// The exercise set's index in the array of exercise sets contained in the workout for this exercise.
    private var exerciseSetIndex: Int

    /// The exercise set's weight property value.
    @State private var exerciseSetWeight: Double
    /// The exercise set's reps property value.
    @State private var exerciseSetReps: Int
    /// The exercise set's completed property value.
    @State private var exerciseSetCompleted: Bool

    enum FocusedField {
        case reps, weight
    }

    /// Boolean to be toggled when an element is in focus.
    @FocusState var inputActive: FocusedField?

    init(exerciseSet: ExerciseSet, exerciseSetIndex: Int) {
        self.exerciseSet = exerciseSet
        self.exerciseSetIndex = exerciseSetIndex

        _exerciseSetWeight = State(wrappedValue: exerciseSet.exerciseSetWeight)
        _exerciseSetReps = State(wrappedValue: exerciseSet.exerciseSetReps)
        _exerciseSetCompleted = State(wrappedValue: exerciseSet.completed)
    }

    var body: some View {
        HStack {
            ExerciseSetCompletionIcon(exerciseSet: exerciseSet)

            if exerciseSet.exercise?.category == 1 {
                HStack {
                    TextField("Weight",
                              value: $exerciseSetWeight.onChange(update),
                              format: .number)
                        .exerciseSetDecimalTextField()
                        .focused($inputActive, equals: .weight)

                    Text("kg")
                }

                Spacer()
            }

            HStack {
                TextField("Reps",
                          value: $exerciseSetReps.onChange(update),
                          format: .number)
                    .exerciseSetIntegerTextField()
                    .focused($inputActive, equals: .reps)

                Text("reps")
            }
        }
    }

    /// Synchronise the @State properties of the view with their Core Data equivalents in whichever ExerciseSet
    /// object is being edited.
    ///
    /// Changes will be announced to any property wrappers observing the exercise set.
    func update() {
        exerciseSet.objectWillChange.send()
        exerciseSet.exercise?.objectWillChange.send()
        exerciseSet.workout?.objectWillChange.send()

        exerciseSet.weight = Double(exerciseSetWeight)
        exerciseSet.reps = Int16(exerciseSetReps)
    }
}

struct BodybuildingExerciseSetView_Previews: PreviewProvider {
    static var previews: some View {
        BodybuildingExerciseSetView(exerciseSet: ExerciseSet.example, exerciseSetIndex: 1)
    }
}