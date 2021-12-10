//
//  ExercisesViewModel.swift
//  Olio
//
//  Created by Jake King on 10/12/2021.
//

import CoreData
import Foundation

extension ExercisesView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        private let exercisesController: NSFetchedResultsController<Exercise>
        @Published var exercises = [Exercise]()
        var dataController: DataController

        init(dataController: DataController) {
            self.dataController = dataController

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

            super.init()
            exercisesController.delegate = self

            do {
                try exercisesController.performFetch()
                exercises = exercisesController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch exercises.")
            }
        }

        var sortedExercises: [Exercise] {
            return exercises.sorted { first, second in
                if first.muscleGroup < second.muscleGroup {
                    return true
                } else if first.muscleGroup > second.muscleGroup {
                    return false
                }

                return first.exerciseName < second.exerciseName
            }
        }

        func filterByMuscleGroup(_ muscleGroup: Exercise.MuscleGroup.RawValue,
                                 exercises: [Exercise]) -> [Exercise] {
            return exercises.filter {$0.exerciseMuscleGroup == muscleGroup}
        }

        func swipeToDeleteExercise(exercises: [Exercise], at offset: Int) {
            let exercise = exercises[offset]
            dataController.delete(exercise)
            dataController.save()
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newExercises = controller.fetchedObjects as? [Exercise] {
                exercises = newExercises
            }
        }
    }
}
