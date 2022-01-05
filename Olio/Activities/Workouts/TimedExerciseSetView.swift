//
//  CardioExerciseSetView.swift
//  Olio
//
//  Created by Jake King on 05/01/2022.
//

import SwiftUI

struct CardioExerciseSetView: View {
    /// The exercise set used to construct this view.
    @ObservedObject var exerciseSet: ExerciseSet

    /// The exercise set's index in the array of exercise sets contained in the workout for this exercise.
    private var exerciseSetIndex: Int

    /// The exercise set's distance property value.
    @State private var exerciseSetDistance: Double
    /// The exercise set's duration property value.
    @State private var exerciseSetDuration: Int
    /// The exercise set's completed property value.
    @State private var exerciseSetCompleted: Bool

    enum FocusedField {
        case distance, duration
    }

    /// Boolean to be toggled when an element is in focus.
    @FocusState var inputActive: FocusedField?

    init(exerciseSet: ExerciseSet, exerciseSetIndex: Int) {
        self.exerciseSet = exerciseSet
        self.exerciseSetIndex = exerciseSetIndex

        _exerciseSetDistance = State(wrappedValue: exerciseSet.exerciseSetDistance)
        _exerciseSetDuration = State(wrappedValue: exerciseSet.exerciseSetDuration)
        _exerciseSetCompleted = State(wrappedValue: exerciseSet.completed)
    }
    
    var body: some View {
        HStack {
            ExerciseSetCompletionIcon(exerciseSet: exerciseSet)

            if exerciseSet.exercise?.category == 1 {
                TextField("Distance",
                          value: $exerciseSetDistance.onChange(update),
                          format: .number)
                    .exerciseSetDecimalTextField()
                    .focused($inputActive)

                Text("km")

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

struct CardioExerciseSetView_Previews: PreviewProvider {
    static var previews: some View {
        CardioExerciseSetView(exerciseSet: ExerciseSet.example, exerciseSetIndex: 1)
    }
}
