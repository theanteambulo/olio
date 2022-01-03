//
//  TemplatesViewModel.swift
//  Olio
//
//  Created by Jake King on 09/12/2021.
//

import CoreData
import Foundation

extension TemplatesView {
    /// A presentation model representing the state of TemplatesView capable of reading model data and carrying out all
    /// transformations needed to prepare that data for presentation.
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        /// Performs the initial fetch request and ensures it remains up to date.
        private let templatesController: NSFetchedResultsController<Workout>

        /// An array of Workout objects.
        @Published var templates = [Workout]()

        /// Dependency injection of the environment singleton responsible for managing the Core Data stack.
        let dataController: DataController

        init(dataController: DataController) {
            self.dataController = dataController

            // Get all the templates.
            let templatesRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
            templatesRequest.predicate = NSPredicate(format: "template = true")
            templatesRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.name,
                                                                 ascending: true)]

            templatesController = NSFetchedResultsController(
                fetchRequest: templatesRequest,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            // Set the class as the delegate of the fetched results controller so it announces when the data changes.
            super.init()
            templatesController.delegate = self

            // Execute the fetch request and assign fetched objects to the templates property.
            do {
                try templatesController.performFetch()
                templates = templatesController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch templates.")
            }
        }

        /// Notifies TemplatesView when the underlying array of workouts changes.
        /// - Parameter controller: The controller that manages the results of the view model's Core Data fetch request.
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newTemplates = controller.fetchedObjects as? [Workout] {
                templates = newTemplates
            }
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
    }
}
