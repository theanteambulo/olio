//
//  WorkoutsViewModel.swift
//  Olio
//
//  Created by Jake King on 09/12/2021.
//

import CoreData
import Foundation

extension WorkoutsView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        let dataController: DataController
        let showingCompletedWorkouts: Bool
        private let workoutsController: NSFetchedResultsController<Workout>
        @Published var workouts = [Workout]()

        init(dataController: DataController,
             showingCompletedWorkouts: Bool) {
            self.dataController = dataController
            self.showingCompletedWorkouts = showingCompletedWorkouts

            // Get all the workouts.
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

            super.init()
            workoutsController.delegate = self

            do {
                try workoutsController.performFetch()
                workouts = workoutsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch workouts.")
            }
        }

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

        var workoutDates: [Date] {
            var dates = [Date]()

            for workout in workouts {
                if !dates.contains(Calendar.current.startOfDay(for: workout.workoutDate)) {
                    dates.append(Calendar.current.startOfDay(for: workout.workoutDate))
                }
            }

            return dates
        }

        func addTemplate() {
            let workout = Workout(context: dataController.container.viewContext)
            workout.id = UUID()
            workout.date = Date()
            workout.completed = false
            workout.template = true
            dataController.save()
        }

        func addWorkout() {
            let workout = Workout(context: dataController.container.viewContext)
            workout.id = UUID()
            workout.date = Date()
            workout.completed = false
            workout.template = false
            dataController.save()
        }

        func createSampleData() {
            dataController.deleteAll()
            try? dataController.createSampleData()
        }

        func filterByDate(_ date: Date,
                          workouts: [Workout]) -> [Workout] {
            return workouts.filter { Calendar.current.startOfDay(for: $0.workoutDate) == date }
        }

        func swipeToDeleteWorkout(_ workouts: [Workout], at offset: Int) {
            let workoutToDelete = workouts[offset]
            dataController.delete(workoutToDelete)
            dataController.save()
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newWorkouts = controller.fetchedObjects as? [Workout] {
                workouts = newWorkouts
            }
        }
    }
}
