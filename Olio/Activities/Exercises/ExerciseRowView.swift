//
//  ExerciseRowView.swift
//  Olio
//
//  Created by Jake King on 24/11/2021.
//

import SwiftUI

/// A single row in the list of all exercises representing a given exercise.
struct ExerciseRowView: View {
    /// The exercise used to construct this view.
    @ObservedObject var exercise: Exercise

    var body: some View {
        NavigationLink(destination: EditExerciseView(exercise: exercise)) {
            Text(exercise.exerciseName)
        }
    }
}

struct ExerciseRowView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseRowView(exercise: Exercise.example)
    }
}
