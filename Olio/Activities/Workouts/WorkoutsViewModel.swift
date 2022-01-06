//
//  WorkoutsViewModel.swift
//  Olio
//
//  Created by Jake King on 09/12/2021.
//

import CoreData
import Foundation

extension WorkoutsView {
    /// A presentation model representing the state of WorkoutsView capable of reading model data and carrying out all
    /// transformations needed to prepare that data for presentation.
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        /// Performs the initial fetch request and ensures it remains up to date.
        private let workoutsController: NSFetchedResultsController<Workout>

        /// An array of Workout objects.
        @Published var workouts = [Workout]()

        /// The environment singleton responsible for managing the Core Data stack.
        let dataController: DataController

        /// Boolean indicating whether completed or scheduled workouts should be displayed.
        let showingCompletedWorkouts: Bool

        init(dataController: DataController,
             showingCompletedWorkouts: Bool) {
            self.dataController = dataController
            self.showingCompletedWorkouts = showingCompletedWorkouts

            // Get all workouts that aren't templates with completed status corresponding to showingCompletedWorkouts.
            let workoutsRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
            let completedWorkoutsPredicate = NSPredicate(format: "completed = %d",
                                                         showingCompletedWorkouts)
            let templateWorkoutsPredicate = NSPredicate(format: "template != true")

            workoutsRequest.predicate = NSCompoundPredicate(type: .and,
                                                            subpredicates: [completedWorkoutsPredicate,
                                                                            templateWorkoutsPredicate])

            workoutsRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.date,
                                                                ascending: true),
                                               NSSortDescriptor(keyPath: \Workout.name,
                                                                ascending: true)]

            workoutsController = NSFetchedResultsController(
                fetchRequest: workoutsRequest,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            // Limit scheduled workouts displayed to 10.
            if !showingCompletedWorkouts {
                workoutsRequest.fetchLimit = 10
            }

            // Set the class as the delegate of the fetched results controller so it announces when the data changes.
            super.init()
            workoutsController.delegate = self

            // Execute the fetch request and assign fetched objects to the workouts property.
            do {
                try workoutsController.performFetch()
                workouts = workoutsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch workouts.")
            }
        }

        /// Computed property to sort workouts by date, then by name.
        ///
        /// Example: Workout X comes before Workout Y on 12 December, which both come before Workout A on 13 December.
        var sortedWorkouts: [Workout] {
            return workouts.sorted { first, second in
                if first.workoutDate < second.workoutDate {
                    return true
                } else if first.workoutDate > second.workoutDate {
                    return false
                }

                return first.workoutName < second.workoutName
            }
        }

        /// Computed property to get all dates corresponding to the date property of all workouts.
        var workoutDates: [Date] {
            var dates = [Date]()

            for workout in workouts {
                if !dates.contains(Calendar.current.startOfDay(for: workout.workoutDate)) {
                    dates.append(Calendar.current.startOfDay(for: workout.workoutDate))
                }
            }

            return dates
        }

        /// Creates a new template workout.
        func addTemplate() {
            let workout = Workout(context: dataController.container.viewContext)
            workout.id = UUID()
            workout.date = Date()
            workout.completed = false
            workout.template = true
            dataController.save()
        }

        /// Creates a new workout.
        func addWorkout() {
            let workout = Workout(context: dataController.container.viewContext)
            workout.id = UUID()
            workout.date = Date()
            workout.completed = false
            workout.template = false
            dataController.save()
        }

        /// Generates sample data for the app.
        ///
        /// Used for development purposes only.
        func createSampleData() {
            dataController.deleteAll()
            try? dataController.createSampleData()
        }

        /// Filters a given array of workouts based on whether their date property matches a given date.
        /// - Parameters:
        ///   - date: The date to filter workouts by.
        ///   - workouts: The array of workouts to filter.
        /// - Returns: An array of workouts.
        func filterByDate(_ date: Date,
                          workouts: [Workout]) -> [Workout] {
            return workouts.filter { Calendar.current.startOfDay(for: $0.workoutDate) == date }
        }

        /// Toggles a given workout's completion status.
        /// - Parameter workout: The workout to toggle completion status of.
        func toggleWorkoutCompletionStatus(_ workout: Workout) {
            workout.completed.toggle()
        }

        /// Deletes a workout from the Core Data context.
        /// - Parameter workout: The workout to delete.
        func deleteWorkout(_ workout: Workout) {
            dataController.delete(workout)
            dataController.save()
        }

        /// Notifies WorkoutsView when the underlying array of workouts changes.
        /// - Parameter controller: The controller that manages the results of the view model's Core Data fetch request.
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newWorkouts = controller.fetchedObjects as? [Workout] {
                workouts = newWorkouts
            }
        }
    }
}
