//
//  WorkoutView.swift
//  Olio
//
//  Created by Jake King on 23/11/2021.
//

import SwiftUI

struct WorkoutView: View {
    let workout: Workout

    var body: some View {
        NavigationView {
            List {
                ForEach(workout.workoutExercises) { exercise in
                    Text(exercise.exerciseName)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(workout.workoutName)
        }
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView(workout: Workout.example)
    }
}
