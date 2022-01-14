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
    func removeExercise(_ exercise: Exercise, fromWorkout workout: Workout) {
        var existingExercises = workout.workoutExercises
        existingExercises.removeAll { $0.id == exercise.id }

        workout.setValue(NSSet(array: existingExercises), forKey: "exercises")

        for exerciseSet in exercise.exerciseSets.filter({ $0.workout == workout }) {
            container.viewContext.delete(exerciseSet)
        }
    }

    /// Saves a new exercise set to the Core Data context.
    /// - Parameters:
    ///   - exercise: The exercise that is parent of the exercise set being created.
    ///   - workout: The workout that is parent of the exercise set being created.
    func addSet(toExercise exercise: Exercise, inWorkout workout: Workout) {
        let workoutSets = exercise.exerciseSets.filter({ $0.workout == workout })
        var setToReplicate: ExerciseSet?

        if workoutSets.isEmpty {
            setToReplicate = exercise.exerciseSets.last
        } else {
            setToReplicate = workoutSets.last
        }

        if workoutSets.count < 99 {
            let set = ExerciseSet(context: container.viewContext)
            set.id = UUID()
            set.workout = workout
            set.exercise = exercise
            set.weight = setToReplicate?.exerciseSetWeight == 1000 ? 999 : setToReplicate?.exerciseSetWeight ?? 0
            set.reps = Int16(setToReplicate?.exerciseSetReps == 1000 ? 999 : setToReplicate?.exerciseSetReps ?? 10)
            set.distance = setToReplicate?.exerciseSetDistance ?? 3

            if exercise.exerciseCategory == "Class" {
                set.duration = Int16(setToReplicate?.exerciseSetDuration ?? 60)
            } else {
                set.duration = Int16(setToReplicate?.exerciseSetDuration ?? 15)
            }

            set.creationDate = Date()
        }

        save()
    }

    /// Create a workout or template from a given workout or template.
    /// - Parameters:
    ///   - workout: The workout to use as the basis for creating a new workout.
    ///   - isTemplate: Boolean to indicate whether the workout being created is a template or not.
    ///   - scheduledOn: The date the new workout is scheduled on.
    func createNewWorkoutOrTemplateFromExisting(_ workout: Workout,
                                                isTemplate: Bool,
                                                scheduledOn date: Date? = nil) {
        let viewContext = container.viewContext

        let newWorkout = Workout(context: viewContext)
        newWorkout.id = UUID()
        newWorkout.name = workout.workoutName
        newWorkout.date = date
        newWorkout.createdDate = Date.now
        newWorkout.completed = false

        if isTemplate {
            newWorkout.template = true
        } else {
            newWorkout.template = false
        }

        var newWorkoutSets = [ExerciseSet]()

        for exerciseSet in workout.workoutExerciseSets.sorted(by: \ExerciseSet.exerciseSetCreationDate) {
            let exerciseSetToAdd = ExerciseSet(context: viewContext)
            exerciseSetToAdd.id = UUID()
            exerciseSetToAdd.workout = newWorkout
            exerciseSetToAdd.exercise = exerciseSet.exercise
            exerciseSetToAdd.weight = Double(exerciseSet.exerciseSetWeight)
            exerciseSetToAdd.reps = Int16(exerciseSet.exerciseSetReps)
            exerciseSetToAdd.distance = Double(exerciseSet.exerciseSetDistance)
            exerciseSetToAdd.duration = Int16(exerciseSet.exerciseSetDuration)
            exerciseSetToAdd.creationDate = Date()
            exerciseSetToAdd.completed = false

            newWorkoutSets.append(exerciseSetToAdd)
        }

        newWorkout.exercises = NSSet(array: workout.workoutExercises)
        newWorkout.sets = NSSet(array: newWorkoutSets)
    }

    /// Completes all sets for a given exercise in a given workout.
    /// - Parameters:
    ///   - exercise: The exercise to which the sets to complete belong.
    ///   - workout: The workout to which the sets to complete belong.
    func completeAllSets(forExercise exercise: Exercise, inWorkout workout: Workout) {
        let allExerciseSetsInWorkout = exercise.exerciseSets.filter({ $0.workout == workout })

        allExerciseSetsInWorkout.forEach({ $0.completed = true })
    }

    /// Completes the next incomplete set for a given exercise in a given workout.
    /// - Parameters:
    ///   - exercise: The exercise to which the set to complete belongs.
    ///   - workout: The workout to which the set to complete belongs.
    func completeNextSet(forExercise exercise: Exercise, inWorkout workout: Workout) {
        // swiftlint:disable:next line_length
        let allSets = exercise.exerciseSets.filter({ $0.workout == workout && $0.completed == false }).sorted(by: \.exerciseSetCreationDate)
        allSets.first?.completed = true
    }

    /// Performs batch delete request for a given fetch request.
    /// - Parameter fetchRequest: A fetch request.
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        // Prepare the batch delete request.
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        // Ensure IDs of deleted objects are sent back as array.
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            // Put array of deleted object IDs into a dictionary.
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]

            // Use dictionary to update view context with changes made to the persistent store.
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }

    /// Deletes all workouts, exercises and sets from the Core Data context.
    func deleteAll() {
        let workoutsFetchRequest: NSFetchRequest<NSFetchRequestResult> = Workout.fetchRequest()
        delete(workoutsFetchRequest)

        let exercisesFetchRequest: NSFetchRequest<NSFetchRequestResult> = Exercise.fetchRequest()
        delete(exercisesFetchRequest)

        let exerciseSetsFetchRequest: NSFetchRequest<NSFetchRequestResult> = ExerciseSet.fetchRequest()
        delete(exerciseSetsFetchRequest)
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

    /// Loads the exercises stored in OlioExercises.json.
    func loadExerciseLibrary() {
        let olioExercises = OlioExercise.allOlioExercises

        for exercise in olioExercises {
            let newCoreDataExercise = Exercise(context: container.viewContext)
            newCoreDataExercise.id = UUID()
            newCoreDataExercise.name = exercise.name
            newCoreDataExercise.category = exercise.category
            newCoreDataExercise.muscleGroup = exercise.muscleGroup
        }
    }
}
