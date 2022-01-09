//
//  ExercisesViewModel.swift
//  Olio
//
//  Created by Jake King on 10/12/2021.
//

import CoreData
import Foundation

extension ExercisesView {
    /// A presentation model representing the state of ExercisesView capable of reading model data and carrying out all
    /// transformations needed to prepare that data for presentation.
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        /// Performs the initial fetch request and ensures it remains up to date.
        private let exercisesController: NSFetchedResultsController<Exercise>

        /// An exercise category selected by the user.
        @Published var exerciseCategory: String

        /// An array of Exercise objects.
        @Published var exercises = [Exercise]()

        /// Dependency injection of the environment singleton responsible for managing the Core Data stack.
        let dataController: DataController

        init(dataController: DataController) {
            self.dataController = dataController
            self.exerciseCategory = "Weights"

            // Get all the exercises.
            let exercisesRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
            exercisesRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.muscleGroup,
                                                                 ascending: true),
                                                NSSortDescriptor(keyPath: \Exercise.name, ascending: true)]

            exercisesController = NSFetchedResultsController(
                fetchRequest: exercisesRequest,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            // Set the class as the delegate of the fetched results controller so it announces when the data changes.
            super.init()
            exercisesController.delegate = self

            // Execute the fetch request and assign fetched objects to the exercises property.
            do {
                try exercisesController.performFetch()
                exercises = exercisesController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch exercises.")
            }
        }

        /// Computed property to sort exercises by muscle group, then by name.
        ///
        /// Example: Bench comes before Flys in Chest, which both come before Squats in Legs.
        var sortedExercises: [Exercise] {
            return filterByExerciseCategory(exerciseCategory,
                                            exercises: exercises).sorted { first, second in
                if first.muscleGroup < second.muscleGroup {
                    return true
                } else if first.muscleGroup > second.muscleGroup {
                    return false
                }

                return first.exerciseName < second.exerciseName
            }
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

        func filterByExerciseCategory(_ exerciseCategory: Exercise.ExerciseCategory.RawValue,
                                      exercises: [Exercise]) -> [Exercise] {
            return exercises.filter { $0.exerciseCategory == exerciseCategory }
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

        /// Notifies ExercisesView when the underlying array of exercises changes.
        /// - Parameter controller: The controller that manages the results of the view model's Core Data fetch request.
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            exercises = controller.fetchedObjects as? [Exercise] ?? []
        }
    }
}
