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
                    Section(header: Text(exercise.exerciseName)) {
                        ForEach(exercise.exerciseSets) { exerciseSet in
                            Text("\(exerciseSet.exerciseSetReps)")
                        }
                    }
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
