//
//  ExerciseRowTabView.swift
//  Olio
//
//  Created by Jake King on 24/11/2021.
//

import SwiftUI

/// A single row in the list of all exercises representing a given exercise.
struct ExerciseRowTabView: View {
    /// The exercise used to construct this view.
    @ObservedObject var exercise: Exercise

    var body: some View {
        NavigationLink(destination: EditExerciseView(exercise: exercise)) {
            HStack {
                Circle()
                    .frame(width: 7)
                    .foregroundColor(exercise.getExerciseCategoryColor())

                Text(exercise.exerciseName)
            }
        }
    }
}

struct ExerciseTabRowView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseRowTabView(exercise: Exercise.example)
    }
}
