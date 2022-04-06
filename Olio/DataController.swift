//
//  DataController.swift
//  Olio
//
//  Created by Jake King on 22/11/2021.
//

import CoreData
import CoreSpotlight
import SwiftUI
import UserNotifications

/// An environment singleton responsible for managing our Core Data stack, including handling saving, counting fetch
/// requests and dealing with sample data.
// swiftlint:disable:next type_body_length
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

            // Ensure the persistent container remains up to date with changes made elsewhere.
            self.container.viewContext.automaticallyMergesChangesFromParent = true

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
            let placement = Placement(context: viewContext)
            workout.id = UUID()
            exercise.id = UUID()
            placement.id = UUID()
            placement.indexPosition = 0
            workout.name = "Workout - \(workoutCount)"
            workout.placements = [placement]
            exercise.name = "Exercise - \(workoutCount)"
            exercise.workouts = [workout]
            exercise.placements = [placement]

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
            print("The context has unsaved changes that have been made...")
            do {
                print("Attempting to save changes to context...")
                try container.viewContext.save()
                print("Changes saved.")
            } catch {
                print("There was a problem saving the Core Data context: \(error.localizedDescription)")
            }
        }
    }

    /// Deletes a given object from the Core Data context and Spotlight.
    /// - Parameter object: The NSManagedObject to delete from the Core Data context and Spotlight.
    func delete(_ object: NSManagedObject) {
        let id = object.objectID.uriRepresentation().absoluteString

        if object is Workout {
            // If the object is a Workout then make sure it's deleted from Spotlight too
            CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id])
        }

        container.viewContext.delete(object)
    }

    /// Removes an exercise from a workout by setting the value of a workout's "exercises" key.
    /// - Parameters:
    ///   - exercise: The exercise to remove.
    ///   - workout: The workout to remove the exercise from.
    func removeExercise(_ exercise: Exercise, fromWorkout workout: Workout) {
        var existingExercises = workout.workoutExercises
        existingExercises.removeAll { $0.id == exercise.id }

        let firstOfFilteredPlacements = exercise.exercisePlacements.filter({ $0.workout == workout }).first

        if let placementToDelete = firstOfFilteredPlacements {
            delete(placementToDelete)
        }

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
            set.completed = workout.template ? true : false
        }
    }

    /// Creates a new workout or template.
    func createNewWorkoutOrTemplate(isTemplate: Bool, daysOffset: Double?) {
        let newWorkout = Workout(context: container.viewContext)
        newWorkout.id = UUID()
        newWorkout.date = Date.now + ((daysOffset ?? 0) * 86400)
        newWorkout.createdDate = Date.now
        newWorkout.completed = false

        if isTemplate {
            newWorkout.name = "New Template"
            newWorkout.template = true
        } else {
            newWorkout.name = "New Workout"
            newWorkout.template = false
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
        newWorkout.date = date
        newWorkout.createdDate = Date.now
        newWorkout.completed = false

        if isTemplate {
            newWorkout.name = "New Template (\(workout.workoutName))"
            newWorkout.template = true
        } else {
            newWorkout.name = "\(workout.workoutName)"
            newWorkout.template = false
        }

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
            exerciseSetToAdd.completed = isTemplate ? true : false

            newWorkout.addToSets(exerciseSetToAdd)
            save()
        }

        for exercisePlacement in workout.workoutPlacements {
            let exercisePlacementToAdd = Placement(context: viewContext)
            exercisePlacementToAdd.id = UUID()
            exercisePlacementToAdd.workout = workout
            exercisePlacementToAdd.exercise = exercisePlacement.exercise
            exercisePlacementToAdd.indexPosition = Int16(exercisePlacement.placementIndexPosition)

            newWorkout.addToPlacements(exercisePlacementToAdd)
            save()
        }
        newWorkout.addToExercises(NSSet(array: workout.workoutExercises))
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

    /// Updates the set of exercises that the workout is parent of to include a given exercise.
    /// - Parameter exercise: The exercise to make a child of the workout.
    func addExercises(_ exercises: [Exercise], toWorkout workout: Workout) {
        workout.objectWillChange.send()

        // If there are any exercises that have placements but aren't in the exercisesToAdd array then delete them
        for placement in workout.workoutPlacements {
            if let exercise = placement.exercise {
                if !exercises.contains(exercise) {
                     // Delete the placement - this exercise is no longer in the workout, so shouldn't have a placement
                    delete(placement)
                    save()
                }
            }
        }

        // Update the order of the exercises for the workout to reflect addition of new exercise.
        updateOrderOfExercises(toMatch: exercises, forWorkout: workout)
    }

    /// Updates the order of the exercises held by a given workout to match a given array of exercises.
    /// - Parameters:
    ///   - exercises: The array of exercises to match the order of.
    ///   - workout: The workout to update.
    func updateOrderOfExercises(toMatch exercises: [Exercise], forWorkout workout: Workout) {
        workout.objectWillChange.send()

        for exercise in exercises {
            // There's either going to be a single placement object, or nothing at all in the array
            let placementsOfExerciseInWorkout = exercise.exercisePlacements.filter({ $0.workout == workout })

            if placementsOfExerciseInWorkout.isEmpty {
                // We've not recorded the placement of this exercise in the workout yet, create a new placement object
                let exercisePlacement = Placement(context: container.viewContext)
                exercisePlacement.id = UUID()
                exercisePlacement.workout = workout
                exercisePlacement.exercise = exercise
                exercisePlacement.indexPosition = Int16(exercises.firstIndex(of: exercise) ?? 0)
            } else {
                // We've previously recorded the placement of this exercise in the workout, update the placement index
                placementsOfExerciseInWorkout.first?.indexPosition = Int16(exercises.firstIndex(of: exercise) ?? 0)
            }
        }

        // Update the exercises for this workout
        workout.setValue(NSSet(array: exercises), forKey: "exercises")

        // Save the changes in Core Data
        save()
    }

    /// Gets the positional index of a given exercise in a given workout.
    /// - Parameters:
    ///   - exercise: The Exercise object whose position is needed.
    ///   - workout: A Workout in which the Exercise is contained.
    func getPlacement(forExercise exercise: Exercise, inWorkout workout: Workout) -> Int? {
        return exercise.exercisePlacements.filter({ $0.workout == workout }).first?.placementIndexPosition
    }

    /// Writes a Workout's information to Spotlight and calls save() method to ensure Core Data is updated too.
    /// - Parameter workout: The workout to be updated and saved.
    func updateWorkout(_ workout: Workout) {
        // Create a unique identifier for the workout being saved
        let workoutId = workout.objectID.uriRepresentation().absoluteString

        // Define the attributes of the workout to be stored in Spotlight
        let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
        attributeSet.title = workout.name

        // Wrap the identifier and attributes in a Spotlight record, optionally passing in a domain identifier
        let searchableItem = CSSearchableItem(
            uniqueIdentifier: workoutId,
            domainIdentifier: nil,
            attributeSet: attributeSet
        )

        // Send the Spotlight record to Spotlight for indexing
        CSSearchableIndex.default().indexSearchableItems([searchableItem])

        save()
    }

    /// Fetches a Workout indexed within Spotlight using a given unique identifier.
    /// - Parameter uniqueIdentifier: The unique identifier of the Workout to fetch.
    /// - Returns: The fetched Workout object if it exists.
    func fetchSpotlightWorkout(withId uniqueIdentifier: String) -> Workout? {
        // Convert the unique identifier for the object ID in Spotlight into a URL
        guard let url = URL(string: uniqueIdentifier) else {
            return nil
        }

        // Get the object id for the object at that URL
        guard let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else {
            return nil
        }

        // Return the object for that id as a workout
        return try? container.viewContext.existingObject(with: id) as? Workout
    }

    /// Adds a reminder for a workout.
    /// - Parameters:
    ///   - workout: The workout the reminder is being added for.
    ///   - completion: A closure to be called on completion.
    func addReminders(for workout: Workout, completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestNotifications { success in
                    if success {
                        self.placeReminders(for: workout, completion: completion)
                    } else {
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                }
            case .authorized:
                self.placeReminders(for: workout, completion: completion)
            default:
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }

    /// Removes a reminder for a workout.
    /// - Parameter workout: The workout the reminder is being removed from.
    func removeReminders(for workout: Workout) {
        let center = UNUserNotificationCenter.current()
        let id = workout.objectID.uriRepresentation().absoluteString
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }

    /// Requests notification privileges from the user.
    /// - Parameter completion: A closure to be called on completion.
    func requestNotifications(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            completion(granted)
        }
    }

    /// Places a single notification for a workout.
    /// - Parameters:
    ///   - workout: The workout for which the notification is being placed.
    ///   - completion: A closure to be called on completion.
    private func placeReminders(for workout: Workout, completion: @escaping (Bool) -> Void) {
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = workout.workoutName

        // Pluralisation doesn't seem to work in local notifications in iOS 15, so manual pluralisation has been done.
        var exercisesString = ""
        var setsString = ""

        switch workout.workoutExercises.count {
        case 0:
            exercisesString = "No exercises, "
        case 1:
            exercisesString = "1 exercise, "
        default:
            exercisesString = "\(workout.workoutExercises.count) exercises, "
        }

        switch workout.workoutExerciseSets.count {
        case 0:
            setsString = "no sets"
        case 1:
            setsString = "1 set"
        default:
            setsString = "\(workout.workoutExercises.count) set"
        }

        content.subtitle = exercisesString + setsString

        let components = Calendar.current.dateComponents([.hour, .minute],
                                                         from: workout.reminderTime ?? Date())
        let trigger = UNCalendarNotificationTrigger(dateMatching: components,
                                                    repeats: false)
        let id = workout.objectID.uriRepresentation().absoluteString
        let request = UNNotificationRequest(identifier: id,
                                            content: content,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if error == nil {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
// swiftlint:disable:next file_length
}
