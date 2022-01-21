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

    /// Tests that when a workout is deleted its placements and sets are also deleted, but the number of exercises is
    /// unaffected.
    func testDeletingWorkoutCascadeDeletesPlacementsAndSetsNotExercises() throws {
        try dataController.createSampleData()

        let request = NSFetchRequest<Workout>(entityName: "Workout")
        let workouts = try managedObjectContext.fetch(request)

        dataController.delete(workouts[0])

        XCTAssertEqual(
            dataController.count(for: Workout.fetchRequest()),
            4,
            "1 workout deleted - there should be 4 workouts remaining."
        )

        XCTAssertEqual(
            dataController.count(for: Exercise.fetchRequest()),
            5,
            "Deleting a workout does not delete the exercise - there should be 5 exercises remaining."
        )

        XCTAssertEqual(
            dataController.count(for: Placement.fetchRequest()),
            4,
            "Deleting a workout deletes its placements - there should be 4 placements remaining."
        )

        XCTAssertEqual(
            dataController.count(for: ExerciseSet.fetchRequest()),
            12,
            "Deleting a workout deletes its sets - there should be 12 placements remaining."
        )
    }

    /// Tests that when an exercise is deleted its placements and sets are also deleted, but the number of workouts is
    /// unaffected.
    func testDeletingExerciseCascadeDeletesSetsNotWorkouts() throws {
        try dataController.createSampleData()

        let request = NSFetchRequest<Exercise>(entityName: "Exercise")
        let exercises = try managedObjectContext.fetch(request)

        dataController.delete(exercises[0])

        XCTAssertEqual(
            dataController.count(for: Workout.fetchRequest()),
            5,
            "Deleting an exercise does not delete the workout - there should be 5 exercises remaining."
        )

        XCTAssertEqual(
            dataController.count(for: Exercise.fetchRequest()),
            4,
            "1 exercise deleted - there should be 4 exercises remaining."
        )

        XCTAssertEqual(
            dataController.count(for: Placement.fetchRequest()),
            4,
            "Deleting an exercise deletes its placements - there should be 4 placements remaining."
        )

        XCTAssertEqual(
            dataController.count(for: ExerciseSet.fetchRequest()),
            12,
            "Deleting an exercise deletes its sets - there should be 12 placements remaining."
        )
    }

    /// Tests that when an exercise set is deleted the number of workouts, exercises and placements are unaffected.
    func testDeletingExerciseSetsNoCascadeDeleteExercisesOrWorkouts() throws {
        try dataController.createSampleData()

        let request = NSFetchRequest<ExerciseSet>(entityName: "ExerciseSet")
        let exerciseSets = try managedObjectContext.fetch(request)

        dataController.delete(exerciseSets[0])

        XCTAssertEqual(
            dataController.count(for: Workout.fetchRequest()),
            5,
            "Deleting an exercise set does not delete its workout - there should be 5 workouts remaining."
        )

        XCTAssertEqual(
            dataController.count(for: Exercise.fetchRequest()),
            5,
            "Deleting an exercise set does not delete its exercise - there should be 5 exercises remaining."
        )

        XCTAssertEqual(
            dataController.count(for: Placement.fetchRequest()),
            5,
            "Deleting an exercise set does not delete any placements - there should be 5 placements remaining."
        )

        XCTAssertEqual(
            dataController.count(for: ExerciseSet.fetchRequest()),
            14,
            "1 exercise set deleted -  there should be 14 exercise sets remaining."
        )
    }

    /// Tests that the Olio exercise library is created successfully.
    func testLoadingOlioExerciseLibrary() {
        dataController.loadExerciseLibrary()

        XCTAssertEqual(
            dataController.count(for: Workout.fetchRequest()),
            0,
            "Loading the exercise library should create 0 workouts."
        )

        XCTAssertEqual(
            dataController.count(for: Exercise.fetchRequest()),
            52,
            "Loading the exercise library should create 52 exercises."
        )

        XCTAssertEqual(
            dataController.count(for: Placement.fetchRequest()),
            0,
            "Loading the exercise library should create 0 placements."
        )

        XCTAssertEqual(
            dataController.count(for: ExerciseSet.fetchRequest()),
            0,
            "Loading the exercise library should create 0 exercise sets."
        )
    }
}
