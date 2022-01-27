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

    var repsInvalid: Bool {
        filteredExerciseSets.compactMap({ $0.exerciseSetReps <= 999 }).contains(false)
    }

    var weightInvalid: Bool {
        filteredExerciseSets.compactMap({ $0.exerciseSetWeight <= 999 }).contains(false)
    }

    var distanceInvalid: Bool {
        filteredExerciseSets.compactMap({ $0.exerciseSetDistance <= 999 }).contains(false)
    }

    var durationInvalid: Bool {
        filteredExerciseSets.compactMap({ $0.exerciseSetDuration <= 999 }).contains(false)
    }

    var exerciseSetsInvalid: Bool {
        repsInvalid || weightInvalid || distanceInvalid || durationInvalid
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
            .disabled(exerciseSetsInvalid)
        }
    }

    func deleteExerciseSetSwipeActionButton(_ exerciseSet: ExerciseSet) -> some View {
        // Delete workout
        Button {
            withAnimation {
                deleteExerciseSet(exerciseSet: exerciseSet)
            }
        } label: {
            Label(Strings.deleteButton.localized, systemImage: "trash")
                .labelStyle(.titleAndIcon)
        }
        .tint(.red)
    }

    func toggleCompletionStatusForExerciseSetSwipeActionButton(_ exerciseSet: ExerciseSet) -> some View {
        // Complete/incomplete exerciseSet
        Button {
            withAnimation {
                toggleCompletionStatusForExerciseSet(exerciseSet)
                update()
            }
        } label: {
            if exerciseSet.completed {
                Label(Strings.incompleteButton.localized, systemImage: "xmark.circle")
                    .labelStyle(.titleAndIcon)
            } else {
                Label(Strings.completeButton.localized, systemImage: "checkmark.circle")
                    .labelStyle(.titleAndIcon)
            }
        }
        .tint(exerciseSet.completed ? .orange : .green)
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(Array(zip(filteredExerciseSets.indices, filteredExerciseSets)), id: \.1) { index, exerciseSet in
                    Group {
                        switch exercise.category {
                        case 1:
                            BodybuildingExerciseSetView(exerciseSet: exerciseSet, exerciseSetIndex: index)
                        case 2:
                            BodybuildingExerciseSetView(exerciseSet: exerciseSet, exerciseSetIndex: index)
                        default:
                            TimedExerciseSetView(exerciseSet: exerciseSet, exerciseSetIndex: index)
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        toggleCompletionStatusForExerciseSetSwipeActionButton(exerciseSet)
                    }
                    .swipeActions(edge: .trailing) {
                        deleteExerciseSetSwipeActionButton(exerciseSet)
                    }
                }

                // Add a set
                Button {
                    withAnimation {
                        dataController.addSet(toExercise: exercise, inWorkout: workout)
                        update()
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

    /// Deletes a given exercise set from the Core Data context.
    /// - Parameter exerciseSet: The exercise set to delete.
    func deleteExerciseSet(exerciseSet: ExerciseSet) {
        dataController.delete(exerciseSet)
        dataController.save()
    }

    /// Toggles the completion status of a given exercise set.
    /// - Parameter exerciseSet: The exercise set whose completion status will be toggle.
    func toggleCompletionStatusForExerciseSet(_ exerciseSet: ExerciseSet) {
        exerciseSet.completed.toggle()
        dataController.save()
    }
}

struct ExerciseSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseSheetView(workout: Workout.example, exercise: Exercise.example)
    }
}
