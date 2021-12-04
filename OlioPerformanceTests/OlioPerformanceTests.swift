//
//  OlioPerformanceTests.swift
//  OlioPerformanceTests
//
//  Created by Jake King on 04/12/2021.
//

import CoreData
import XCTest
@testable import Olio

class PerformanceTestCase: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}
