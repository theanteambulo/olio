//
//  HomeViewModel.swift
//  Olio
//
//  Created by Jake King on 09/01/2022.
//

import CoreData
import Foundation

extension HomeView {
    /// A presentation model representing the state of WorkoutsListView capable of reading model data and carrying out
    /// all transformations needed to prepare that data for presentation.
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        /// The environment singleton responsible for managing the Core Data stack.
        let dataController: DataController
        /// Boolean indicating whether completed or scheduled workouts should be displayed.
        let showingCompletedWorkouts: Bool

        /// Performs the initial fetch request and ensures it remains up to date.
        private var workoutsController: NSFetchedResultsController<Workout>

        /// An array of Workout objects.
        @Published var workouts = [Workout]()
        /// An array Date objects.
        @Published var workoutDates = [Date]()

        init(dataController: DataController,
             showingCompletedWorkouts: Bool) {
            self.dataController = dataController
            self.showingCompletedWorkouts = showingCompletedWorkouts

            // Initialise the fetch request.
            let workoutsRequest: NSFetchRequest<Workout> = Workout.fetchRequest()

            // Get all non-template workouts with completion status corresponding to showingCompletedWorkouts.
            let templatePredicate = NSPredicate(format: "template != true")
            let completionPredicate = NSPredicate(format: "completed = %d", showingCompletedWorkouts)
            workoutsRequest.predicate = NSCompoundPredicate(type: .and,
                                                            subpredicates: [templatePredicate,
                                                                            completionPredicate])
            // Sort workouts by date, then by name.
            workoutsRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.date, ascending: true)]

            // Limit scheduled workouts displayed to 99.
            if !showingCompletedWorkouts {
                workoutsRequest.fetchLimit = 10
            }

            workoutsController = NSFetchedResultsController(
                fetchRequest: workoutsRequest,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            // Set the class as the delegate of the fetched results controller so it announces when the data changes.
            super.init()
            workoutsController.delegate = self

            // Execute the fetch request and assign fetched objects to the workouts property.
            do {
                try workoutsController.performFetch()
                workouts = workoutsController.fetchedObjects?.sorted(by: \.workoutDate) ?? []
                workoutDates = workouts.map({ Calendar.current.startOfDay(for: $0.workoutDate) }).removingDuplicates()
            } catch {
                print("Failed to fetch workouts: \(error.localizedDescription)")
            }
        }

        /// Notifies WorkoutsListView when the underlying array of workouts changes.
        /// - Parameter controller: The controller that manages the results of the view model's Core Data fetch request.
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            workouts = workoutsController.fetchedObjects?.sorted(by: \.workoutDate) ?? []
            workoutDates = workouts.map({ Calendar.current.startOfDay(for: $0.workoutDate) }).removingDuplicates()
        }

        /// Creates a new workout.
        func addWorkout(dayOffset: Double) {
            let newWorkout = Workout(context: dataController.container.viewContext)
            newWorkout.id = UUID()
            newWorkout.name = nil
            newWorkout.date = Date.now + (dayOffset * 86400)
            newWorkout.createdDate = Date.now
            newWorkout.completed = false
            newWorkout.template = false
        }

        /// Returns a date offset by a given number of days from today.
        /// - Parameter dayOffset: The number of days offset from the current date the workout option will be.
        /// - Returns: A date offset by a given number of days from today.
        func date(for dayOffset: Int) -> Date {
            let dateOption = Date.now + Double(dayOffset * 86400)
            return dateOption
        }

        /// Toggles the completion status of a given workout.
        /// - Parameter workout: The workout whose completion status will be toggle.
        func toggleCompletionStatusForWorkout(_ workout: Workout) {
            workout.completed.toggle()
            dataController.save()
        }

        /// Deletes a given workout from the Core Data context.
        /// - Parameter workout: The workout to delete.
        func deleteWorkout(_ workout: Workout) {
            dataController.delete(workout)
            dataController.save()
        }

        func filterWorkouts(_ workouts: [Workout], by date: Date) -> [Workout] {
            let filteredWorkouts = workouts.filter({ Calendar.current.startOfDay(for: $0.workoutDate) == date })
            return filteredWorkouts
        }

        func deleteAll() {
            dataController.deleteAll()
            dataController.save()
        }
    }
}
