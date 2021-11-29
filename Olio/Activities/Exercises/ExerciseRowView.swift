//
//  ExerciseRowView.swift
//  Olio
//
//  Created by Jake King on 24/11/2021.
//

import SwiftUI

struct ExerciseRowView: View {
    @ObservedObject var exercise: Exercise

    var body: some View {
        NavigationLink(destination: EditExerciseView(exercise: exercise)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(exercise.exerciseName)
                    Text(exercise.exerciseId)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
    }
}

struct ExerciseRowView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseRowView(exercise: Exercise.example)
    }
}
