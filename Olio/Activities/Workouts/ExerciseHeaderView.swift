//
//  ExerciseHeaderView.swift
//  Olio
//
//  Created by Jake King on 30/11/2021.
//

import SwiftUI

struct ExerciseHeaderView: View {
    @ObservedObject var workout: Workout
    @ObservedObject var exercise: Exercise

    var body: some View {
        HStack {
            Text("\(Int(100 * exerciseCompletionAmount(exercise)))%")
                .frame(minWidth: 50)
            ProgressView(value: exerciseCompletionAmount(exercise))
        }
    }

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
