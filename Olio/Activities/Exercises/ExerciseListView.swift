//
//  ExerciseListView.swift
//  Olio
//
//  Created by Jake King on 13/01/2022.
//

import SwiftUI

struct ExerciseListView: View {
    /// The environment singleton used to manage the Core Data stack.
    var dataController: DataController
    /// The array of Exercise objects used to construct this view.
    var exercises: [Exercise]

    /// Provides functionality for dismissing a presentation.
    ///
    /// Used in this view for dismissing a sheet.
    @Environment(\.dismiss) var dismiss

    init(dataController: DataController,
         exercises: [Exercise]) {
        self.dataController = dataController
        self.exercises = exercises
    }

    /// The muscle groups the exercises passed in belong to.
    var muscleGroups: [Exercise.MuscleGroup.RawValue] {
        exercises.compactMap({ $0.exerciseMuscleGroup }).removingDuplicates()
    }

    var body: some View {
        List {
            ForEach(muscleGroups, id: \.self) { muscleGroup in
                Section(header: Text(muscleGroup)) {
                    ForEach(filterByMuscleGroup(muscleGroup,
                                                exercises: exercises)) { exercise in
                        ExerciseRowTabView(exercise: exercise)
                    }
                    .onDelete { offsets in
                        let allExercises = filterByMuscleGroup(muscleGroup,
                                                               exercises: exercises)

                        for offset in offsets {
                            swipeToDeleteExercise(exercises: allExercises,
                                                  at: offset)
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }

    /// Filters a given array of exercises based on whether their muscleGroup property matches a given muscle group.
    /// - Parameters:
    ///   - muscleGroup: The muscle group to filter the array of exercises by.
    ///   - exercises: The array of exercises to filter.
    /// - Returns: An array of exercises.
    func filterByMuscleGroup(_ muscleGroup: Exercise.MuscleGroup.RawValue,
                             exercises: [Exercise]) -> [Exercise] {
        return exercises.filter { $0.exerciseMuscleGroup == muscleGroup }
    }

    /// Deletes an exercise based on its position in a given array of exercises.
    /// - Parameters:
    ///   - exercises: The array of exercises.
    ///   - offset: The position of the exercise to delete in the given array of exercises.
    func swipeToDeleteExercise(exercises: [Exercise], at offset: Int) {
        let exercise = exercises[offset]
        dataController.delete(exercise)
        dataController.save()
    }
}

struct ExerciseListView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseListView(dataController: DataController.preview,
                         exercises: [Exercise.example])
    }
}
