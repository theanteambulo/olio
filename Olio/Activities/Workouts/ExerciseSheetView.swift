//
//  ExerciseSheetView.swift
//  Olio
//
//  Created by Jake King on 04/01/2022.
//

import SwiftUI

struct ExerciseSheetView: View {
    /// The workout object used to construct this view.
    @ObservedObject var workout: Workout

    /// The exercise object used to construct this view.
    @ObservedObject var exercise: Exercise

    /// The environment singleton responsible for managing the Core Data stack.
    @EnvironmentObject var dataController: DataController

    @Environment(\.dismiss) var dismiss

    init(workout: Workout, exercise: Exercise) {
        self.workout = workout
        self.exercise = exercise
    }

    var filteredExerciseSets: [ExerciseSet] {
        exercise.exerciseSets.filter({ $0.workout == workout }).sorted(by: \.exerciseSetCreationDate)
    }

    var keyboardDoneButton: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()

            Button("Done") {
                hideKeyboard()
            }
        }
    }

    var sheetCloseButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                hideKeyboard()
                dismiss()
            } label: {
                Label("Close", systemImage: "xmark")
            }
        }
    }

    var sheetSaveButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(Strings.saveButton.localized) {
                hideKeyboard()
                update()
                dismiss()
            }
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(Array(zip(filteredExerciseSets.indices, filteredExerciseSets)), id: \.1) { index, exerciseSet in
                    switch exercise.category {
                    case 1:
                        Section(header: Text("Set \(index + 1)")) {
                            BodybuildingExerciseSetView(exerciseSet: exerciseSet, exerciseSetIndex: index)
                        }
                    case 2:
                        Section(header: Text("Set \(index + 1)")) {
                            BodybuildingExerciseSetView(exerciseSet: exerciseSet, exerciseSetIndex: index)
                        }
                    default:
                        Section(header: Text("Set \(index + 1)")) {
                            TimedExerciseSetView(exerciseSet: exerciseSet, exerciseSetIndex: index)
                        }
                    }
                }
                .onDelete { offsets in
                    let allExerciseSets = filteredExerciseSets

                    for offset in offsets {
                        let exerciseSetToDelete = allExerciseSets[offset]
                        deleteExerciseSet(exerciseSet: exerciseSetToDelete)
                    }
                }

                // Add a set
                Button {
                    withAnimation {
                        addSet(toExercise: exercise, toWorkout: workout)
                    }
                } label: {
                    Label(Strings.addSet.localized, systemImage: "plus")
                }
                .accessibilityIdentifier("Add Set to Exercise: \(exercise.exerciseName)")
                .disabled(exercise.exerciseSets.filter({ $0.workout == workout }).count >= 99)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(exercise.exerciseName)
            .toolbar {
                keyboardDoneButton
                sheetCloseButton
                sheetSaveButton
            }
        }
    }

    /// Synchronise the @State properties of the view with their Core Data equivalents in whichever ExerciseSet
    /// object is being edited.
    ///
    /// Changes will be announced to any property wrappers observing the exercise set.
    func update() {
        workout.objectWillChange.send()
        exercise.objectWillChange.send()
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

    /// Deletes a given exercise set from the Core Data context.
    /// - Parameter exerciseSet: The exercise set to delete.
    func deleteExerciseSet(exerciseSet: ExerciseSet) {
        dataController.delete(exerciseSet)
        dataController.save()
    }
}

struct ExerciseSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseSheetView(workout: Workout.example, exercise: Exercise.example)
    }
}
