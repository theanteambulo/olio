//
//  TimedExerciseSetView.swift
//  Olio
//
//  Created by Jake King on 05/01/2022.
//

import SwiftUI

/// A single row for a cardio, class or stretch exercise in a workout representing a set added to that exercise.
struct TimedExerciseSetView: View {
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

    /// Boolean indicating if the current exercise set values result in an error.b
    @State private var exerciseSetError: ExerciseSetError?

    /// Boolean to be toggled when an element is in focus.
    @FocusState var inputActive: FocusedField?

    init(exerciseSet: ExerciseSet, exerciseSetIndex: Int) {
        self.exerciseSet = exerciseSet
        self.exerciseSetIndex = exerciseSetIndex

        _exerciseSetDistance = State(wrappedValue: exerciseSet.exerciseSetDistance)
        _exerciseSetDuration = State(wrappedValue: exerciseSet.exerciseSetDuration)
        _exerciseSetCompleted = State(wrappedValue: exerciseSet.completed)
    }

    var exerciseSetDistanceInvalid: Bool {
        exerciseSetDistance > 999
    }

    var exerciseSetDurationInvalid: Bool {
        exerciseSetDuration > 999
    }

    var setCount: String {
        return "Set \(exerciseSetIndex + 1)"
    }

    var accessibilityIdentifier: String {
        let durationUnit = "\(exerciseSet.exercise?.category == 5 ? "seconds" : "minutes")"
        let durationString = "\(exerciseSet.exerciseSetDuration) \(durationUnit)"
        let distanceString = "\(exerciseSet.exerciseSetDistance) kilometres"
        let usageInstructions = "Swipe right to complete, left to delete."
        
        if exerciseSet.exercise?.exerciseCategory == "Cardio" {
            return setCount + ": " + durationString + ", " + distanceString + ". " + usageInstructions
        } else if exerciseSet.exercise?.exerciseCategory == "Class" {
            return setCount + ": " + durationString + ". " + usageInstructions
        } else {
            return setCount + ": " + durationString + ". " + usageInstructions + "."
        }
    }

    var body: some View {
        Section(header: Text(setCount),
                footer: SectionFooterErrorMessage(exerciseSetError: $exerciseSetError,
                                                  exerciseSetStretch: exerciseSet.exercise?.category == 5)) {
            HStack {
                ExerciseSetCompletionIcon(exerciseSet: exerciseSet)

                if exerciseSet.exercise?.category == 3 {
                    HStack {
                        TextField("Distance",
                                  value: $exerciseSetDistance.onChange(exerciseSetDistanceOnChangeHandler),
                                  format: .number)
                            .exerciseSetDecimalTextField()
                            .focused($inputActive, equals: .distance)
                            .foregroundColor(exerciseSetDistanceInvalid ? .red : .primary)

                        Text("km")
                    }

                    Spacer()
                }

                HStack {
                    TextField("Duration",
                              value: $exerciseSetDuration.onChange(exerciseSetDurationOnChangeHandler),
                              format: .number)
                        .exerciseSetIntegerTextField()
                        .focused($inputActive, equals: .duration)
                        .foregroundColor(exerciseSetDurationInvalid ? .red : .primary)

                    Text(exerciseSet.exercise?.category == 5 ? "secs" : "mins")
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityIdentifier(accessibilityIdentifier)
        }
        .onDisappear(perform: onDisappearSetExerciseSetValuesIfError)
    }

    /// Determines whether the reps for the exercise set are valid, modifies the rep count if required and calls the
    /// update method.
    func exerciseSetDistanceOnChangeHandler() {
        if exerciseSetDistance <= 999 {
            if exerciseSetError != nil && exerciseSetError != .distance {
                // Set equal to .duration - the reps are valid and there's an error somewhere else
                exerciseSetError = .duration
            } else {
                // Set equal to nil - may have been a distance error previously but now no errors so we should hide it
                exerciseSetError = nil
            }
        } else {
            exerciseSetDistance = 1000

            if exerciseSetError == .distance {
                // Do nothing - there are no errors elsewhere and we're already correctly showing the distance error
            } else if exerciseSetError != nil && exerciseSetError != .distance {
                // Set equal to .distanceAndDuration - there's some other error somewhere but now also a distance error
                exerciseSetError = .distanceAndDuration
            } else {
                // Set equal to .distance - there were no existing errors but now a distance error exists
                exerciseSetError = .distance
            }
        }

        update()
    }

    /// Determines whether the reps for the exercise set are valid, modifies the rep count if required and calls the
    /// update method.
    func exerciseSetDurationOnChangeHandler() {
        if exerciseSetDuration <= 999 {
            if exerciseSetError != nil && exerciseSetError != .duration {
                // Set equal to .distance - the duration is valid and there's an error somewhere else
                exerciseSetError = .distance
            } else {
                // Set equal to nil - may have been a duration error previously but now no errors so we should hide it
                exerciseSetError = nil
            }
        } else {
            exerciseSetDuration = 1000

            if exerciseSetError == .duration {
                // Do nothing - there are no errors elsewhere and we're already correctly showing the duration error
            } else if exerciseSetError != nil && exerciseSetError != .duration {
                // Set equal to .distanceAndDuration - there's some other error somewhere but now also a duration error
                exerciseSetError = .distanceAndDuration
            } else {
                // Set equal to .duration - there were no existing errors but now a duration error exists
                exerciseSetError = .duration
            }
        }

        update()
    }

    func onDisappearSetExerciseSetValuesIfError() {
        switch exerciseSetError {
        case .distance:
            exerciseSetDistance = 999
        case .duration:
            exerciseSetDuration = 999
        case .distanceAndDuration:
            exerciseSetDistance = 999
            exerciseSetDuration = 999
        default:
            exerciseSetDistance = exerciseSetDistance
            exerciseSetDuration = exerciseSetDuration
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

        exerciseSet.distance = Double(exerciseSetDistance)
        exerciseSet.duration = Int16(exerciseSetDuration)
    }
}

struct TimedExerciseSetView_Previews: PreviewProvider {
    static var previews: some View {
        TimedExerciseSetView(exerciseSet: ExerciseSet.example, exerciseSetIndex: 1)
    }
}
