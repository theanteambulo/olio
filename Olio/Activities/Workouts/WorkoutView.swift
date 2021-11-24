//
//  WorkoutView.swift
//  Olio
//
//  Created by Jake King on 23/11/2021.
//

import SwiftUI

struct WorkoutView: View {
    let workout: Workout

    @State private var showEditWorkoutSheet = false

    var body: some View {
        NavigationView {
            List {
                ForEach(workout.workoutExercises) { exercise in
                    Section(header: Text(exercise.exerciseName)) {
                        ForEach(exercise.exerciseSets) { exerciseSet in
                            HStack {
                                Text("\(exerciseSet.exerciseSetReps) reps")

                                Spacer()

                                if exerciseSet.completed {
                                    Image(systemName: "checkmark.circle")
                                        .foregroundColor(.green)
                                } else {
                                    Image(systemName: "xmark.circle")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(workout.workoutName)
            .navigationBarItems(
                trailing: Button("Edit") { showEditWorkoutSheet.toggle() }
                    .sheet(isPresented: $showEditWorkoutSheet) {
                        EditWorkoutView(workout: workout)
                    }
            )
        }
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView(workout: Workout.example)
    }
}
