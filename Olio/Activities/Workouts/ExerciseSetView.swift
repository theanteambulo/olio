//
//  ExerciseSetView.swift
//  Olio
//
//  Created by Jake King on 27/11/2021.
//

import SwiftUI

struct ExerciseSetView: View {
    @ObservedObject var exerciseSet: ExerciseSet

    @State private var exerciseSetReps: Int
    @State private var exerciseSetCompleted: Bool

    init(exerciseSet: ExerciseSet) {
        self.exerciseSet = exerciseSet

        _exerciseSetReps = State(wrappedValue: exerciseSet.exerciseSetReps)
        _exerciseSetCompleted = State(wrappedValue: exerciseSet.completed)
    }

    var completionIcon: String {
        exerciseSet.completed ? "checkmark" : "xmark"
    }

    var iconColor: Color {
        exerciseSet.completed ? .green : .red
    }

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
