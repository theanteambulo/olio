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

    /// Initialises a DataController either in memory (for temporary use such as testing and previewing), or in
    /// permanent storage (for use in regular app runs).
    ///
    /// Defaults to permanent storage.
    /// - Parameter inMemory: Whether to store data in temporary storage or not.
    init(inMemory: Bool = false) {
        // Load the data model.
        container = NSPersistentCloudKitContainer(name: "Main")

        // Create data in memory when true for testing/previewing purposes.
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        // Load/create the database on disk.
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load storage: \(error.localizedDescription)")
            }
        }
    }

    /// Creates example workouts and exercises to make manual testing easier.
    ///  - Throws: An NSError sent from calling save() on the NSManagedObjectContext.
    func createSampleData() throws {
        // Data loaded from disk to work with.
        let viewContext = container.viewContext

        // Create 5 sample workouts, each with 5 sample exercises.
        for workoutCount in 1...5 {
            let workout = Workout(context: viewContext)
            workout.name = "Workout \(workoutCount)"
            workout.template = Bool.random()
            workout.dateScheduled = Date()
            workout.dateCompleted = Date()
            workout.completed = Bool.random()
            workout.exercises = []

            for exerciseCount in 1...5 {
                let exercise = Exercise(context: viewContext)
                exercise.name = "Exercise \(exerciseCount)"
                exercise.bodyweight = Bool.random()
                exercise.muscleGroup = Int16(exerciseCount)
                exercise.reps = 10
                exercise.sets = 3
                exercise.workouts = [workout]
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

    /// Batch deletes all workouts and exercises from the Core Data context.
    func deleteAll() {
        let workoutFetchRequest: NSFetchRequest<NSFetchRequestResult> = Workout.fetchRequest()
        let workoutBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: workoutFetchRequest)
        _ = try? container.viewContext.execute(workoutBatchDeleteRequest)

        let exerciseFetchRequest: NSFetchRequest<NSFetchRequestResult> = Exercise.fetchRequest()
        let exerciseBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: exerciseFetchRequest)
        _ = try? container.viewContext.execute(exerciseBatchDeleteRequest)
    }
}
