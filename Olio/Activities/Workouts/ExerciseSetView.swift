//
//  ExerciseSetView.swift
//  Olio
//
//  Created by Jake King on 27/11/2021.
//

import SwiftUI

/// A single row for an exercise in a workout representing a set added to that exercise.
///
/// Used a component to construct EditWorkoutExerciseListView.
struct ExerciseSetView: View {
    /// The exercise set used to construct this view.
    @ObservedObject var exerciseSet: ExerciseSet

    /// The exercise set's reps property value.
    @State private var exerciseSetReps: Int
    /// The exercise set's weight property value.
    @State private var exerciseSetWeight: Double
    /// The exercise set's distance property value.
    @State private var exerciseSetDistance: Double
    /// The exercise set's duration property value.
    @State private var exerciseSetDuration: Int
//    /// A special version of the exercise set's duration property value for use on cardio exercises only.
//    @State private var exerciseSetCardioDuration: String
    /// The exercise set's complete property value.
    @State private var exerciseSetCompleted: Bool

    /// Boolean indicating whether the sheet to input cardio exercise duration is being displayed.
    @State private var displayDurationInputSheet = false

    enum FocusedField {
        case reps, weight, distance, duration
    }

    /// Boolean to be toggled when an element is in focus.
    @FocusState private var focusedField: FocusedField?

    init(exerciseSet: ExerciseSet) {
        self.exerciseSet = exerciseSet

        _exerciseSetReps = State(wrappedValue: exerciseSet.exerciseSetReps)
        _exerciseSetWeight = State(wrappedValue: exerciseSet.exerciseSetWeight)
        _exerciseSetDistance = State(wrappedValue: exerciseSet.exerciseSetDistance)
        _exerciseSetDuration = State(wrappedValue: exerciseSet.exerciseSetDuration)
        _exerciseSetCompleted = State(wrappedValue: exerciseSet.completed)

//        _exerciseSetCardioDuration = State(wrappedValue: "")
    }

    /// Computed string representing the name of the icon that should be displayed.
    var completionIcon: String {
        exerciseSet.completed
        ? "checkmark.circle.fill"
        : "circle"
    }

    /// Computed string representing the colour of the icon that should be displayed.
    var iconColor: Color {
        exerciseSet.completed
        ? .green
        : .red
    }

    /// The accessibility label of the icon displayed.
    var iconAccessibilityLabel: Text {
        exerciseSet.completed
        ? Text("\(exerciseSetReps) reps") + Text(". Mark set incomplete")
        : Text("\(exerciseSetReps) reps") + Text(". Mark set complete")
    }

    var body: some View {
        HStack {
            HStack {
                if !(exerciseSet.workout?.template ?? true) {
                    Image(systemName: completionIcon)
                        .frame(width: 25)
                        .foregroundColor(iconColor)
                        .onTapGesture {
                            withAnimation {
                                exerciseSet.completed.toggle()
                                update()
                            }
                        }
                        .accessibilityLabel(iconAccessibilityLabel)
                        .accessibilityAddTraits(.isButton)
                }

                // Only weighted exercises should have weight text field.
                if exerciseSet.exercise?.exerciseCategory == "Weights" {
                    HStack {
                        TextField("Weight",
                                  value: $exerciseSetWeight.onChange(update),
                                  format: .number)
                            .frame(width: 75)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .weight)

                        Text("kg")
                    }

                    Spacer()
                }

                // Weighted and bodyweight exercises should have reps field.
                if exerciseSet.exercise?.category == 1 || exerciseSet.exercise?.category == 2 {
                    HStack {
                        TextField("Reps",
                                  value: $exerciseSetReps.onChange(update),
                                  format: .number)
                            .frame(width: 75)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .reps)

                        Text("reps")
                    }
                }

                // Only cardio should have a distance field and a special duration field.
                if exerciseSet.exercise?.category == 3 {
                    HStack {
                        TextField("Distance",
                                  value: $exerciseSetDistance.onChange(update),
                                  format: .number)
                            .frame(width: 75)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .distance)

                        Text("km")

                        Spacer()

//                        TextField("mm:ss",
//                                  text: $exerciseSetCardioDuration)
//                            .frame(width: 75)
//                            .textFieldStyle(.roundedBorder)
//                            .keyboardType(.decimalPad)
//                            .focused($focusedField, equals: .duration)
                    }
                }

                // Classes and stretches should have a duration field.
                if exerciseSet.exercise?.category == 4 || exerciseSet.exercise?.category == 5 {
                    HStack {
                        TextField("Duration",
                                  value: $exerciseSetDuration.onChange(update),
                                  format: .number)
                            .frame(width: 75)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .duration)

                        Text(exerciseSet.exercise?.category == 4
                             ? "mins"
                             : "secs")

                        Spacer()
                    }
                }
            }

            Spacer()

            if focusedField != nil {
                Button("Done", action: hideKeyboard)
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

        exerciseSet.reps = Int16(exerciseSetReps)
        exerciseSet.weight = Double(exerciseSetWeight)
        exerciseSet.distance = Double(exerciseSetDistance)
        exerciseSet.duration = Int16(exerciseSetDuration)
    }
}

/// Force hides any keyboard currently being displayed.
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil,
                                        from: nil,
                                        for: nil)
    }
}
#endif

struct ExerciseSetView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseSetView(exerciseSet: ExerciseSet.example)
    }
}
