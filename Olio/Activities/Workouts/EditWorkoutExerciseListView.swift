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

            Button("Add Set") {
                withAnimation {
                    addSet(toExercise: exercise, toWorkout: workout)
                    print("A set was added to the exercise.")
                }
            }

            Button("Remove Exercise", role: .destructive) {
                showingDeleteExerciseConfirmation.toggle()
            }
            .tint(.red)
            .alert("Are you sure?",
                   isPresented: $showingDeleteExerciseConfirmation) {
                Button("Remove", role: .destructive) {
                    withAnimation {
                        dataController.removeExerciseFromWorkout(exercise, workout)
                        dataController.save()
                    }
                }

                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Removing an exercise from the workout also deletes all of its sets and cannot be undone.")
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
