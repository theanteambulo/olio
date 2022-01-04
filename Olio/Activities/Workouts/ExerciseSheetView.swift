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

    @Environment(\.dismiss) var dismiss

    init(workout: Workout, exercise: Exercise) {
        self.workout = workout
        self.exercise = exercise
    }

    var filteredExerciseSets: [ExerciseSet] {
        exercise.exerciseSets.filter({ $0.workout == workout }).sorted(by: \.exerciseSetCreationDate)
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
                        EmptyView()
                    }
                }

                // Add a set
                Button {
                    // more code to come
                } label: {
                    Label(Strings.addSet.localized, systemImage: "plus")
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(exercise.exerciseName)
            .toolbar {
                // Close button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Close", systemImage: "xmark")
                    }
                }

                // Save button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(Strings.saveButton.localized) {
                        update()
                        dismiss()
                    }
                }
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
}

struct ExerciseSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseSheetView(workout: Workout.example, exercise: Exercise.example)
    }
}
