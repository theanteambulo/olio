//
//  TemplatesViewModel.swift
//  Olio
//
//  Created by Jake King on 09/12/2021.
//

import CoreData
import Foundation

extension TemplatesView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        let dataController: DataController
        private let templatesController: NSFetchedResultsController<Workout>
        @Published var templates = [Workout]()

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

            super.init()
            templatesController.delegate = self

            do {
                try templatesController.performFetch()
                templates = templatesController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch templates.")
            }
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newTemplates = controller.fetchedObjects as? [Workout] {
                templates = newTemplates
            }
        }
    }
}
