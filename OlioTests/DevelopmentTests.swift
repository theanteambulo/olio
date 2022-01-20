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
    /// Tests the createSampleData() method of the DataController class to ensure that when called the correct number
    /// of Workout, Exercise, Placement and ExerciseSet objects are created.
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

    /// Tests the deleteAll() method of the DataController class to ensure that when called no Workout, Exercise,
    /// Placement or ExerciseSet objects remain.
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
            dataController.count(for: Placement.fetchRequest()),
            0,
            "There should be 0 placements."
        )
        XCTAssertEqual(
            dataController.count(for: ExerciseSet.fetchRequest()),
            0,
            "There should be 0 exercise sets."
        )
    }

    /// Tests example workouts are completed by default.
    func testExampleWorkoutIsCompleted() {
        let workout = Workout.example

        XCTAssert(
            workout.completed,
            "Example workout should be completed by default."
        )
    }

    /// Tests example exercises are weighted by default.
    func testExampleExerciseIsWeighted() {
        let exercise = Exercise.example

        XCTAssert(
            exercise.category == 0,
            "Example exercise category should be 0 ('Weights') by default."
        )
    }

    /// Tests example placements have the index position 0 by default.
    func testExamplePlacementHasIndexZero() {
        let placement = Placement.example

        XCTAssert(
            placement.indexPosition == 0,
            "Example placement index position should be 0 by default."
        )
    }

    /// Tests example exercise sets are incomplete by default.
    func testExampleExerciseSetIsIncomplete() {
        let exerciseSet = ExerciseSet.example

        XCTAssert(
            !exerciseSet.completed,
            "Example exercise set should be incomplete by default."
        )
    }
}
