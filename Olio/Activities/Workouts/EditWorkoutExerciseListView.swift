//
//  EditWorkoutExerciseListView.swift
//  Olio
//
//  Created by Jake King on 01/12/2021.
//

import SwiftUI

struct EditWorkoutExerciseListView: View {
    @ObservedObject var workout: Workout
    @ObservedObject var exercise: Exercise

    @EnvironmentObject var dataController: DataController

    @State private var showingDeleteExerciseConfirmation = false

    var body: some View {
        Section(header: Text("\(exercise.exerciseName)")) {
            ExerciseHeaderView(workout: workout,
                               exercise: exercise)

            ForEach(filterExerciseSets(exercise.exerciseSets), id: \.self) { exerciseSet in
                ExerciseSetView(exerciseSet: exerciseSet)
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

            Button(Strings.addSet.localized) {
                withAnimation {
                    addSet(toExercise: exercise, toWorkout: workout)
                }
            }
            .accessibilityIdentifier("Add Set to Exercise: \(exercise.exerciseName)")

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

    func filterExerciseSets(_ exerciseSets: [ExerciseSet]) -> [ExerciseSet] {
        exerciseSets.filter { $0.workout == workout }.sorted(by: \ExerciseSet.exerciseSetCreationDate)
    }

    func deleteExerciseSet(exerciseSet: ExerciseSet) {
        dataController.delete(exerciseSet)
        dataController.save()
    }

    func addSet(toExercise exercise: Exercise,
                toWorkout workout: Workout) {
        let set = ExerciseSet(context: dataController.container.viewContext)
        set.id = UUID()
        set.workout = workout
        set.exercise = exercise
        set.reps = 10
        set.creationDate = Date()
        dataController.save()
    }
}

struct EditWorkoutExerciseListView_Previews: PreviewProvider {
    static var previews: some View {
        EditWorkoutExerciseListView(workout: Workout.example, exercise: Exercise.example)
    }
}
