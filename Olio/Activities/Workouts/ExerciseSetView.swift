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

    var body: some View {
        HStack {
            Image(systemName: "tortoise.fill")
                .foregroundColor(exerciseSet.completed ? .green : .red)
                .onTapGesture {
                    exerciseSetCompleted.toggle()
                    update()
                    print("Exercise completed: \(exerciseSetCompleted)")
                    print("Exercise completed: \(exerciseSet.completed)")
                }

            Stepper(
                value: $exerciseSetReps.onChange(update),
                in: 1...100,
                step: 1
            ) {
                Text("Reps: \(exerciseSetReps)")
            }
        }
    }

    func update() {
        exerciseSet.objectWillChange.send()

        exerciseSet.reps = Int16(exerciseSetReps)
        exerciseSet.completed = exerciseSetCompleted
    }
}

struct ExerciseSetView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseSetView(exerciseSet: ExerciseSet.example)
    }
}
