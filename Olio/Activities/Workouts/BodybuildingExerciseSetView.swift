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

    /// Boolean indicating if the current exercise set values result in an error.b
    @State private var exerciseSetError: ExerciseSetError?

    /// Boolean to be toggled when an element is in focus.
    @FocusState var inputActive: FocusedField?

    init(exerciseSet: ExerciseSet, exerciseSetIndex: Int) {
        self.exerciseSet = exerciseSet
        self.exerciseSetIndex = exerciseSetIndex

        _exerciseSetWeight = State(wrappedValue: exerciseSet.exerciseSetWeight)
        _exerciseSetReps = State(wrappedValue: exerciseSet.exerciseSetReps)
        _exerciseSetCompleted = State(wrappedValue: exerciseSet.completed)
    }

    var exerciseSetRepsInvalid: Bool {
        exerciseSetReps > 999
    }

    var exerciseSetWeightInvalid: Bool {
        exerciseSetWeight > 999
    }

    var setCount: String {
        return "Set \(exerciseSetIndex + 1)"
    }

    var accessibilityIdentifier: String {
        let weightString = "\(exerciseSet.exerciseSetWeight) kilograms"
        let repsString = "\(exerciseSet.exerciseSetReps) reps"
        let usageInstructions = "Swipe right to complete, left to delete."

        if exerciseSet.exercise?.exerciseCategory == "Weights" {
            return setCount + ": " + weightString + ", " + repsString + ". " + usageInstructions
        } else {
            return setCount + ": " + repsString + ". " + usageInstructions + "."
        }
    }

    var body: some View {
        Section(header: Text(setCount),
                footer: SectionFooterErrorMessage(exerciseSetError: $exerciseSetError,
                                                  exerciseSetStretch: exerciseSet.exercise?.category == 5)) {
            HStack {
                ExerciseSetCompletionIcon(exerciseSet: exerciseSet)

                if exerciseSet.exercise?.category == 1 {
                    HStack {
                        TextField("Weight",
                                  value: $exerciseSetWeight.onChange(exerciseSetWeightOnChangeHandler),
                                  format: .number)
                            .exerciseSetDecimalTextField()
                            .focused($inputActive, equals: .weight)
                            .foregroundColor(exerciseSetWeightInvalid ? .red : .primary)

                        Text("kg")
                    }

                    Spacer()
                }

                HStack {
                    TextField("Reps",
                              value: $exerciseSetReps.onChange(exerciseSetRepsOnChangeHandler),
                              format: .number)
                        .exerciseSetIntegerTextField()
                        .focused($inputActive, equals: .reps)
                        .foregroundColor(exerciseSetRepsInvalid ? .red : .primary)

                    Text("reps")
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityIdentifier(accessibilityIdentifier)
        }
        .onDisappear(perform: onDisappearSetExerciseSetValuesIfError)
    }

    /// Determines whether the reps for the exercise set are valid, modifies the rep count if required and calls the
    /// update method.
    func exerciseSetRepsOnChangeHandler() {
        if exerciseSetReps <= 999 {
            if exerciseSetError != nil && exerciseSetError != .reps {
                // Set equal to .weight - the reps are valid and there's an error somewhere else
                exerciseSetError = .weight
            } else {
                // Set equal to nil - may have been a reps error previously but now no errors so we should hide it
                exerciseSetError = nil
            }
        } else {
            exerciseSetReps = 1000

            if exerciseSetError == .reps {
                // Do nothing - there are no errors elsewhere and we're already correctly showing the reps error
            } else if exerciseSetError != nil && exerciseSetError != .reps {
                // Set equal to .repsAndWeight - there's some other error somewhere but now also a reps error
                exerciseSetError = .repsAndWeight
            } else {
                // Set equal to .reps - there were no existing errors but now a reps error exists
                exerciseSetError = .reps
            }
        }

        update()
    }

    /// Determines whether the reps for the exercise set are valid, modifies the rep count if required and calls the
    /// update method.
    func exerciseSetWeightOnChangeHandler() {
        if exerciseSetWeight <= 999 {
            if exerciseSetError != nil && exerciseSetError != .weight {
                // Set equal to .reps - the weight is valid and there's an error somewhere else
                exerciseSetError = .reps
            } else {
                // Set equal to nil - may have been a weight error previously but now no errors so we should hide it
                exerciseSetError = nil
            }
        } else {
            exerciseSetWeight = 1000

            if exerciseSetError == .weight {
                // Do nothing - there are no errors elsewhere and we're already correctly showing the weight error
            } else if exerciseSetError != nil && exerciseSetError != .weight {
                // Set equal to .repsAndWeight - there's some other error somewhere but now also a weight error
                exerciseSetError = .repsAndWeight
            } else {
                // Set equal to .weight - there were no existing errors but now a weight error exists
                exerciseSetError = .weight
            }
        }

        update()
    }

    func onDisappearSetExerciseSetValuesIfError() {
        switch exerciseSetError {
        case .reps:
            exerciseSetReps = 999
        case .weight:
            exerciseSetWeight = 999
        case .repsAndWeight:
            exerciseSetReps = 999
            exerciseSetWeight = 999
        default:
            exerciseSetReps = exerciseSetReps
            exerciseSetWeight = exerciseSetWeight
        }

        update()
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
