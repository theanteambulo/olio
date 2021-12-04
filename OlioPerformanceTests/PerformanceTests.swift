//
//  PerformanceTests.swift
//  OlioPerformanceTests
//
//  Created by Jake King on 04/12/2021.
//

import XCTest
@testable import Olio
import CoreData

class PerformanceTests: PerformanceTestCase {
    func testExerciseSetCompletionCountPerformance() throws {
        for _ in 1...1000 {
            try dataController.createSampleData()
        }

        let request = NSFetchRequest<ExerciseSet>(entityName: "ExerciseSet")
        let allExerciseSets = try managedObjectContext.fetch(request)

        measure {
            _ = allExerciseSets.filter(dataController.exerciseSetComplete)
        }
    }
}
