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

    init(exerciseSet: ExerciseSet) {
        self.exerciseSet = exerciseSet

        _exerciseSetReps = State(wrappedValue: exerciseSet.exerciseSetReps)
    }

    var body: some View {
        HStack {
            ExerciseSetIconView(completed: exerciseSet.completed)
                .onTapGesture {
                    exerciseSet.completed.toggle()
                    update()
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
    }
}

struct ExerciseSetView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseSetView(exerciseSet: ExerciseSet.example)
    }
}
