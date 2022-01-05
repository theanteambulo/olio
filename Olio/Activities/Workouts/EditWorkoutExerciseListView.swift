//
//  EditWorkoutExerciseListView.swift
//  Olio
//
//  Created by Jake King on 01/12/2021.
//

import SwiftUI

/// A section to be used in EditWorkoutView containing the "body" of an exercise for a given workout.
///
/// The "body" of an exercise is in essence a list consisting of an instance of ExerciseHeaderView, instances of
/// ExerciseSetView corresponding to the number of exercise sets in the exercise, followed by buttons to add an
/// additional exercise set to the exercise or remove the exercise from the workout.
struct EditWorkoutExerciseListView: View {
    /// The workout used to construct this view.
    @ObservedObject var workout: Workout

    /// The exercise used to construct this view.
    @ObservedObject var exercise: Exercise

    /// The environment singleton responsible for managing the Core Data stack.
    @EnvironmentObject var dataController: DataController

    /// Boolean to indicate whether the sheet showing the exercise's sets is displayed.
    @State private var showingExerciseSheet = false

    /// Boolean to indicate whether the alert warning the user about deleting the workout is displayed.
    @State private var showingDeleteExerciseConfirmation = false

    var headerView: some View {
        HStack {
            Circle()
                .frame(width: 7)
                .foregroundColor(exercise.getExerciseCategoryColor())

            Text("\(exercise.exerciseName)")
        }
    }

    var body: some View {
        Section(header: headerView) {
            // HStack showing
            // Doughnut with completion amount coloured by exercise category colour
            // Exercise name in headline font
            // # sets, # complete in caption font

            // The exercise header showing progress for non-template workouts.
            if !workout.template {
                ExerciseHeaderView(workout: workout,
                                   exercise: exercise)
            }

            // New exercise sheet view.
            Button(exercise.exerciseName) {
                showingExerciseSheet = true
            }
            .sheet(isPresented: $showingExerciseSheet) {
                ExerciseSheetView(workout: workout, exercise: exercise)
            }
        }
    }
}

struct EditWorkoutExerciseListView_Previews: PreviewProvider {
    static var previews: some View {
        EditWorkoutExerciseListView(workout: Workout.example, exercise: Exercise.example)
    }
}
