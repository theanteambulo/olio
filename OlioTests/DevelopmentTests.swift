//
//  DevelopmentTests.swift
//  OlioTests
//
//  Created by Jake King on 04/12/2021.
//

import CoreData
import XCTest
@testable import Olio

class DevelopmentTests: BaseTestCase {
    func testCreatingSampleData() throws {
        try dataController.createSampleData()

        XCTAssertEqual(
            dataController.count(for: Workout.fetchRequest()),
            5,
            "There should be 5 sample workouts."
        )

        XCTAssertEqual(
            dataController.count(for: Exercise.fetchRequest()),
            5,
            "There should be 5 sample exercises."
        )

        XCTAssertEqual(
            dataController.count(for: Placement.fetchRequest()),
            5,
            "There should be 5 sample placements."
        )

        XCTAssertEqual(
            dataController.count(for: ExerciseSet.fetchRequest()),
            15,
            "There should be 15 sample exercise sets."
        )
    }

    func testDeleteAllRemovesAllDataFromStorage() throws {
        try dataController.createSampleData()

        dataController.deleteAll()

        XCTAssertEqual(
            dataController.count(for: Workout.fetchRequest()),
            0,
            "There should be 0 workouts."
        )

        XCTAssertEqual(
            dataController.count(for: Exercise.fetchRequest()),
            0,
            "There should be 0 exercises."
        )

        XCTAssertEqual(
            dataController.count(for: ExerciseSet.fetchRequest()),
            0,
            "There should be 0 exercise sets."
        )
    }

    func testExampleWorkoutIsCompleted() {
        let workout = Workout.example

        XCTAssert(
            workout.completed,
            "Example workout should be completed by default."
        )
    }

    func testExampleExerciseIsBodyWeight() {
        let exercise = Exercise.example

        XCTAssert(
            exercise.category == 0,
            "Example exercise category should be 0 ('Weights') by default."
        )
    }

    func testExampleExerciseSetIsIncomplete() {
        let exerciseSet = ExerciseSet.example

        XCTAssert(
            !exerciseSet.completed,
            "Example exercise set should be incomplete by default."
        )
    }
}
