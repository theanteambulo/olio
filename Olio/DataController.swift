//
//  DataController.swift
//  Olio
//
//  Created by Jake King on 22/11/2021.
//

import CoreData
import SwiftUI

/// An environment singleton responsible for managing our Core Data stack, including handling saving, counting fetch
/// requests and dealing with sample data.
class DataController: ObservableObject {
    /// The lone CloudKit container used to store all our data.
    let container: NSPersistentCloudKitContainer

    /// A programmatic representation of the data model file describing Core Data objects.
    ///
    /// Ensures the data model is only loaded once, avoiding failures during testing.
    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }

        return managedObjectModel
    }()

    /// Initialises a DataController either in memory (for temporary use such as testing and previewing), or in
    /// permanent storage (for use in regular app runs).
    ///
    /// Defaults to permanent storage.
    /// - Parameter inMemory: Whether to store data in temporary memory or not.
    init(inMemory: Bool = false) {
        // Load the data model exactly once.
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)

        // Create data in memory when true for testing/previewing purposes.
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        // Load/create the database on disk.
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load storage: \(error.localizedDescription)")
            }

            // Ensure each test is started with no prior data and UI tests run without animations.
            #if DEBUG
            if CommandLine.arguments.contains("enable-testing") {
                UIView.setAnimationsEnabled(false)
                self.deleteAll()
            }
            #endif
        }
    }

    /// Creates example workouts and exercises to make manual testing easier.
    ///  - Throws: An NSError sent from calling save() on the NSManagedObjectContext.
    func createSampleData() throws {
        // Data loaded from disk to work with.
        let viewContext = container.viewContext

        // Create 5 sample workouts, each with 1 sample exercise.
        for workoutCount in 1...5 {
            let workout = Workout(context: viewContext)
            let exercise = Exercise(context: viewContext)
            workout.id = UUID()
            exercise.id = UUID()
            workout.name = "Workout - \(workoutCount)"
            exercise.name = "Exercise - \(workoutCount)"
            exercise.workouts = [workout]

            // Create a sample template.
            if workoutCount == 1 {
                workout.template = true
            } else {
                workout.template = false

                // Create sample complete and scheduled workouts.
                if workoutCount.isMultiple(of: 2) {
                    workout.completed = true
                } else {
                    workout.completed = false
                }
            }

            // Create sample exercise sets.
            for exerciseSetCount in 1...3 {
                let exerciseSet = ExerciseSet(context: viewContext)
                exerciseSet.id = UUID()
                exerciseSet.creationDate = Date()
                exerciseSet.exercise = exercise
                exerciseSet.workout = workout

                if exerciseSetCount == 1 {
                    exerciseSet.completed = true
                } else {
                    exerciseSet.completed = false
                }
            }
        }

        // Save changes to the Core Data context.
        try viewContext.save()
    }

    /// An instance of DataController for previewing purposes.
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        let viewContext = dataController.container.viewContext

        do {
            try dataController.createSampleData()
        } catch {
            fatalError("Fatal error creating preview: \(error.localizedDescription)")
        }

        return dataController
    }()

    /// Saves our Core Data context iff there are changes.
    ///
    /// This silently ignores errors caused by saving, but this should be fine given all entity attributes are optional.
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }

    /// Deletes a given object from the Core Data context.
    /// - Parameter object: The NSManagedObject to delete from the Core Data context.
    func delete(_ object: NSManagedObject) {
        container.viewContext.delete(object)
    }

    /// Removes an exercise from a workout by setting the value of a workout's "exercises" key.
    /// - Parameters:
    ///   - exercise: The exercise to remove.
    ///   - workout: The workout to remove the exercise from.
    func removeExerciseFromWorkout(_ exercise: Exercise, _ workout: Workout) {
        var existingExercises = workout.workoutExercises
        existingExercises.removeAll { $0.id == exercise.id }

        workout.setValue(NSSet(array: existingExercises), forKey: "exercises")

        for exerciseSet in exercise.exerciseSets.filter({ $0.workout == workout }) {
            container.viewContext.delete(exerciseSet)
        }
    }

    /// Batch deletes all workouts, exercises and sets from the Core Data context.
    func deleteAll() {
        let workoutFetchRequest: NSFetchRequest<NSFetchRequestResult> = Workout.fetchRequest()
        let workoutBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: workoutFetchRequest)
        _ = try? container.viewContext.execute(workoutBatchDeleteRequest)

        let exerciseFetchRequest: NSFetchRequest<NSFetchRequestResult> = Exercise.fetchRequest()
        let exerciseBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: exerciseFetchRequest)
        _ = try? container.viewContext.execute(exerciseBatchDeleteRequest)

        let exerciseSetFetchRequest: NSFetchRequest<NSFetchRequestResult> = ExerciseSet.fetchRequest()
        let exerciseSetBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: exerciseSetFetchRequest)
        _ = try? container.viewContext.execute(exerciseSetBatchDeleteRequest)
    }

    /// Counts the number of objects in the Core Data context for a given FetchRequest, without actually having to
    /// execute that FetchRequest to get the count.
    /// - Returns: A count of the objects in the Core Data context for a given FetchRequest.
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }

    /// Checks whether a given exercise set has been completed.
    ///
    /// Used for performance testing.
    /// - Parameter exerciseSet: The exercise set to check.
    /// - Returns: Boolean indicating whether the exercise set is completed or not.
    func exerciseSetComplete(exerciseSet: ExerciseSet) -> Bool {
        exerciseSet.completed
    }
}
