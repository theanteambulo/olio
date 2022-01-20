//
//  ProjectTests.swift
//  OlioTests
//
//  Created by Jake King on 04/12/2021.
//

import CoreData
import XCTest
@testable import Olio

class ProjectTests: BaseTestCase {
    /// Tests that there are no entity objects already existing when a new user opens the app.
    func testNewUserHasNoWorkoutsExercisesPlacementsOrExerciseSets() {
        XCTAssertEqual(
            dataController.count(for: Workout.fetchRequest()),
            0,
            "There should be 0 existing workouts."
        )

        XCTAssertEqual(
            dataController.count(for: Exercise.fetchRequest()),
            0,
            "There should be 0 existing exercises."
        )

        XCTAssertEqual(
            dataController.count(for: Placement.fetchRequest()),
            0,
            "There should be 0 existing placements."
        )

        XCTAssertEqual(
            dataController.count(for: ExerciseSet.fetchRequest()),
            0,
            "There should be 0 existing exercise sets."
        )
    }

    /// Tests the correct number of entity objects are created given a target count.
    func testCreatingWorkoutsExercisesPlacementsAndSets() {
        let targetCount = 5

        for _ in 0..<targetCount {
            let workout = Workout(context: managedObjectContext)
            let exercise = Exercise(context: managedObjectContext)
            let placement = Placement(context: managedObjectContext)
            placement.workout = workout
            placement.exercise = exercise
            exercise.workouts = [workout]

            for _ in 0..<targetCount {
                let exerciseSet = ExerciseSet(context: managedObjectContext)
                exerciseSet.exercise = exercise
                exerciseSet.workout = workout
            }
        }

        XCTAssertEqual(
            dataController.count(for: Workout.fetchRequest()),
            targetCount,
            "There should be \(targetCount) workouts."
        )

        XCTAssertEqual(
            dataController.count(for: Exercise.fetchRequest()),
            targetCount,
            "There should be \(targetCount) exercises."
        )

        XCTAssertEqual(
            dataController.count(for: Placement.fetchRequest()),
            targetCount,
            "There should be \(targetCount) placements."
        )

        XCTAssertEqual(
            dataController.count(for: ExerciseSet.fetchRequest()),
            targetCount * targetCount,
            "There should be \(targetCount * targetCount) exercise sets."
        )
    }

    func testDeletingWorkoutCascadeDeletesSetsNotExercises() throws {
        try dataController.createSampleData()

        let request = NSFetchRequest<Workout>(entityName: "Workout")
        let workouts = try managedObjectContext.fetch(request)

        dataController.delete(workouts[0])

        XCTAssertEqual(
            dataController.count(for: Workout.fetchRequest()),
            4
        )

        XCTAssertEqual(
            dataController.count(for: Exercise.fetchRequest()),
            5
        )

        XCTAssertEqual(
            dataController.count(for: ExerciseSet.fetchRequest()),
            12
        )
    }

    func testDeletingExerciseCascadeDeletesSetsNotWorkouts() throws {
        try dataController.createSampleData()

        let request = NSFetchRequest<Exercise>(entityName: "Exercise")
        let exercises = try managedObjectContext.fetch(request)

        dataController.delete(exercises[0])

        XCTAssertEqual(
            dataController.count(for: Workout.fetchRequest()),
            5
        )

        XCTAssertEqual(
            dataController.count(for: Exercise.fetchRequest()),
            4
        )

        XCTAssertEqual(
            dataController.count(for: ExerciseSet.fetchRequest()),
            12
        )
    }

    func testDeletingExerciseSetsNoCascadeDeleteExercisesOrWorkouts() throws {
        try dataController.createSampleData()

        let request = NSFetchRequest<ExerciseSet>(entityName: "ExerciseSet")
        let exerciseSets = try managedObjectContext.fetch(request)

        dataController.delete(exerciseSets[0])

        XCTAssertEqual(
            dataController.count(for: Workout.fetchRequest()),
            5
        )

        XCTAssertEqual(
            dataController.count(for: Exercise.fetchRequest()),
            5
        )

        XCTAssertEqual(
            dataController.count(for: ExerciseSet.fetchRequest()),
            14
        )
    }
}
