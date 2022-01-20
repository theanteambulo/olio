//
//  OlioTests.swift
//  OlioTests
//
//  Created by Jake King on 03/12/2021.
//

import CoreData
import XCTest

// Import all of the main Olio target for testing. This allows us to access all parts of the project directly, without
// needing to declare them as public.
@testable import Olio

class BaseTestCase: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!

    // Create a DataController instance before every test runs so all subsequent tests have access to storage as needed.
    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}

// create a single workout
// with two exercises
// (and therefore two placements)
// each with 3 sets

// test that when an exercise is deleted
// there is only one exercise remaining in the workout
// there is are only three sets remaining in the workout
// all sets belong to the correct exercise
// there is only one placement belonging to the correct exercise

// really, we want to test the array of exercises etc. owned by the workout is correct
