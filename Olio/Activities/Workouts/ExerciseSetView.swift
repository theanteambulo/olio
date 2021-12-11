//
//  ExerciseSetView.swift
//  Olio
//
//  Created by Jake King on 27/11/2021.
//

import SwiftUI

/// A single row for an exercise in a workout representing a set added to that exercise.
struct ExerciseSetView: View {
    /// The exercise set used to construct this view.
    @ObservedObject var exerciseSet: ExerciseSet

    /// The exercise set's reps property value.
    @State private var exerciseSetReps: Int

    /// The exercise set's complete property value.
    @State private var exerciseSetCompleted: Bool

    init(exerciseSet: ExerciseSet) {
        self.exerciseSet = exerciseSet

        _exerciseSetReps = State(wrappedValue: exerciseSet.exerciseSetReps)
        _exerciseSetCompleted = State(wrappedValue: exerciseSet.completed)
    }

    /// Computed string representing the name of the icon that should be displayed.
    var completionIcon: String {
        exerciseSet.completed
        ? "checkmark"
        : "xmark"
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
            Image(systemName: completionIcon)
                .frame(width: 15)
                .foregroundColor(iconColor)
                .onTapGesture {
                    withAnimation {
                        exerciseSet.completed.toggle()
                        update()
                    }
                }
                .accessibilityLabel(iconAccessibilityLabel)
                .accessibilityAddTraits(.isButton)

            Stepper("\(exerciseSetReps) reps",
                    value: $exerciseSetReps.onChange(update),
                    in: 1...100,
                    step: 1)
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
    }
}

struct ExerciseSetView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseSetView(exerciseSet: ExerciseSet.example)
    }
}
