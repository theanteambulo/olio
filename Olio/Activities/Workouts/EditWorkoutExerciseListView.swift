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

            // The exercise sets.
            ForEach(Array(zip(filterExerciseSets(exercise.exerciseSets).indices,
                              filterExerciseSets(exercise.exerciseSets))),
                    id: \.1) { index, exerciseSet in
                ExerciseSetView(exerciseSet: exerciseSet, exerciseSetIndex: index)
            }
            .onDelete { offsets in
                let allExerciseSets = filterExerciseSets(exercise.exerciseSets)

                for offset in offsets {
                    let exerciseSetToDelete = allExerciseSets[offset]

                    withAnimation {
                        deleteExerciseSet(exerciseSet: exerciseSetToDelete)
                    }
                }
            }

            // Button to add an additional exercise set.
            Button(Strings.addSet.localized) {
                withAnimation {
                    addSet(toExercise: exercise, toWorkout: workout)
                }
            }
            .accessibilityIdentifier("Add Set to Exercise: \(exercise.exerciseName)")
            .disabled(exercise.exerciseSets.filter({ $0.workout == workout }).count >= 99)

            // Button to remove the exercise from the workout.
            Button(Strings.removeExerciseButton.localized, role: .destructive) {
                showingDeleteExerciseConfirmation.toggle()
            }
            .tint(.red)
            .alert(Strings.areYouSureAlertTitle.localized,
                   isPresented: $showingDeleteExerciseConfirmation) {
                Button(Strings.removeButton.localized, role: .destructive) {
                    withAnimation {
                        dataController.removeExerciseFromWorkout(exercise, workout)
                        dataController.save()
                    }
                }

                Button(Strings.cancelButton.localized, role: .cancel) { }
            } message: {
                Text(.removeExerciseConfirmationMessage)
            }
        }
    }

    /// Filters a given array of exercise sets based on whether their workout property matches the current workout.
    /// - Parameter exerciseSets: The array of exercise sets to filter.
    /// - Returns: An array of exercise sets.
    func filterExerciseSets(_ exerciseSets: [ExerciseSet]) -> [ExerciseSet] {
        exerciseSets.filter { $0.workout == workout }.sorted(by: \ExerciseSet.exerciseSetCreationDate)
    }

    /// Deletes a given exercise set from the Core Data context.
    /// - Parameter exerciseSet: The exercise set to delete.
    func deleteExerciseSet(exerciseSet: ExerciseSet) {
        dataController.delete(exerciseSet)
        dataController.save()
    }

    /// Saves a new exercise set to the Core Data context.
    /// - Parameters:
    ///   - exercise: The exercise that is parent of the exercise set being created.
    ///   - workout: The workout that is parent of the exercise set being created.
    func addSet(toExercise exercise: Exercise,
                toWorkout workout: Workout) {
        let currentWorkoutExerciseSets = exercise.exerciseSets.filter({ $0.workout == workout })

        if currentWorkoutExerciseSets.count < 99 {
            let set = ExerciseSet(context: dataController.container.viewContext)
            set.id = UUID()
            set.workout = workout
            set.exercise = exercise
            set.weight = currentWorkoutExerciseSets.last?.exerciseSetWeight ?? 0
            set.reps = Int16(currentWorkoutExerciseSets.last?.exerciseSetReps ?? 10)
            set.distance = currentWorkoutExerciseSets.last?.exerciseSetDistance ?? 3

            if exercise.exerciseCategory == "Class" {
                set.duration = Int16(currentWorkoutExerciseSets.last?.exerciseSetDuration ?? 60)
            } else {
                set.duration = Int16(currentWorkoutExerciseSets.last?.exerciseSetDuration ?? 15)
            }

            set.creationDate = Date()
            dataController.save()
        }
    }
}

struct EditWorkoutExerciseListView_Previews: PreviewProvider {
    static var previews: some View {
        EditWorkoutExerciseListView(workout: Workout.example, exercise: Exercise.example)
    }
}
