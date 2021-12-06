//
//  OlioUITests.swift
//  OlioUITests
//
//  Created by Jake King on 04/12/2021.
//

import XCTest

extension XCUIElement {
    func forceTapElement() {
        if self.isHittable {
            self.tap()
        } else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            coordinate.tap()
        }
    }
}

// swiftlint:disable:next type_body_length
class OlioUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
    }

    func testAppHasThreeTabs() throws {
        XCTAssertEqual(
            app.tabBars.buttons.count,
            3,
            "There should be 3 tabs in the app."
        )
    }

    func testHomeTabAddsWorkout() throws {
        XCTAssertEqual(
            app.tables.cells.count,
            0,
            "There should be no workouts initially."
        )

        for workoutCount in 1...5 {
            app.buttons["Add"].tap()
            app.buttons["Add New Workout"].tap()

            XCTAssertEqual(
                app.tables.cells.count,
                workoutCount,
                "There should be \(workoutCount) row(s) in the list."
            )
        }
    }

    func testHomeTabAddsTemplate() throws {
        XCTAssertEqual(
            app.scrollViews.buttons.count,
            0,
            "There should be 0 templates in the scroll view initially."
        )

        for templateCount in 1...5 {
            app.buttons["Add"].tap()
            app.buttons["Add New Template"].tap()

            XCTAssertEqual(
                app.scrollViews.buttons.count,
                templateCount,
                "There should be \(templateCount) templates in the scroll view."
            )
        }
    }

    func testEditingWorkoutName() throws {
        XCTAssertEqual(
            app.tables.cells.count,
            0,
            "There should be 0 workouts initially."
        )

        app.buttons["Add"].tap()
        app.buttons["Add New Workout"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            1,
            "There should be 1 workout in the list."
        )

        app.tables.cells.buttons["New Workout"].tap()

        app.textFields["New Workout"].tap()
        app.keys["more"].tap()
        app.keys["space"].tap()
        app.keys["more"].tap()
        app.keys["2"].tap()
        app.buttons["Return"].tap()

        app.navigationBars.buttons["Home"].tap()

        XCTAssertTrue(
            app.tables.cells.buttons["New Workout 2"].exists,
            "The new workout name should be visible in the list."
        )
    }

    func testEditingTemplateName() throws {
        XCTAssertEqual(
            app.scrollViews.buttons.count,
            0,
            "There should be 0 templates in the scroll view initially."
        )

        app.buttons["Add"].tap()
        app.buttons["Add New Template"].tap()

        XCTAssertEqual(
            app.scrollViews.buttons.count,
            1,
            "There should be 1 template in the scroll view."
        )

        app.scrollViews.buttons["New Template"].tap()

        app.textFields["New Template"].tap()
        app.keys["more"].tap()
        app.keys["space"].tap()
        app.keys["more"].tap()
        app.keys["2"].tap()
        app.buttons["Return"].tap()

        app.navigationBars.buttons["Home"].tap()

        XCTAssertTrue(
            app.scrollViews.buttons["New Template 2"].exists,
            "The new template name should be visible in the list."
        )
    }

    func testEditingWorkoutDate() {
        XCTAssertEqual(
            app.tables.cells.count,
            0,
            "There should be 0 workouts initially."
        )

        app.buttons["Add"].tap()
        app.buttons["Add New Workout"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            1,
            "There should be 1 workout in the list."
        )

        let labelFormatter = DateFormatter()
        labelFormatter.dateFormat = "EEEE, MMMM d, y"

        XCTAssertTrue(
            app.tables.otherElements.staticTexts[labelFormatter.string(from: .now)].exists,
            "A section with a header matching the current date should exist."
        )

        var dateToPick: Date
        var components = DateComponents()
        components.day = 1

        if .now == Calendar.current.date(from: components) {
            dateToPick = Calendar.current.date(byAdding: DateComponents.init(day: 1), to: .now) ?? .now
        } else {
            dateToPick = Calendar.current.date(byAdding: DateComponents.init(day: -1), to: .now) ?? .now
        }

        let buttonFormatter = DateFormatter()
        buttonFormatter.dateFormat = "EEEE, MMMM d"

        app.tables.cells.buttons["New Workout"].tap()
        app.tables.cells.buttons["Workout Date"].tap()
        app.datePickers.element.buttons[buttonFormatter.string(from: dateToPick)].tap()

        XCTAssertTrue(
            app.alerts.element.exists,
            "An alert should be displayed after the user selects a date."
        )

        XCTAssertEqual(
            app.alerts.element.label,
            labelFormatter.string(from: dateToPick),
            "The alert title should match the date the user selected."
        )

        app.alerts.buttons["OK"].tap()
        app.tabBars.buttons["Home"].tap()

        XCTAssertTrue(
            app.tables.otherElements.staticTexts[labelFormatter.string(from: dateToPick)].exists,
            "A section with a header matching the user's selected date should exist."
        )
    }

    func testAddingAnExercise() {
        app.tabBars.buttons["Exercises"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            0,
            "There should be 0 exercises in the list initially."
        )

        app.navigationBars.buttons["Add"].tap()

        app.textFields["Exercise Name"].tap()

        XCTAssertTrue(
            app.keys["B"].waitForExistence(timeout: 1),
            "The keyboard must be visible on screen before being used."
        )

        app.keys["B"].tap()
        app.keys["e"].tap()
        app.keys["n"].tap()
        app.keys["c"].tap()
        app.keys["h"].tap()
        app.buttons["Return"].tap()
        app.buttons["Save"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            1,
            "There should be 1 exercise in the list."
        )

        XCTAssertTrue(
            app.tables.cells.buttons["Bench"].exists,
            "The exercise that the user created should be available as a button in the list."
        )
    }

    func testAddingExerciseToWorkout() {
        testAddingAnExercise()

        app.tabBars.buttons["Home"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            0,
            "There should be no workouts initially."
        )

        app.navigationBars.buttons["Add"].forceTapElement()
        app.buttons["Add New Workout"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            1,
            "There should be 1 workout in the list."
        )

        app.tables.cells.buttons["New Workout"].tap()
        app.navigationBars.buttons["Add"].forceTapElement()
        app.tables.cells.buttons["Bench"].tap()

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["Bench"].exists,
            "A section with a header matching the added exercise's should exist."
        )

        app.navigationBars.buttons["Home"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            1,
            "There should be 1 workout in the list."
        )

        XCTAssertTrue(
            app.tables.cells.staticTexts["1 exercise"].exists,
            "There should be 1 workout in the list with caption text reading '1 exercise'."
        )

        XCTAssertTrue(
            app.tables.cells.staticTexts["No sets"].exists,
            "There should be 1 workout in the scroll view with caption text reading 'No sets'."
        )
    }

    func testAddingExerciseToTemplate() {
        testAddingAnExercise()

        app.tabBars.buttons["Home"].tap()

        XCTAssertEqual(
            app.scrollViews.buttons.count,
            0,
            "There should be 0 templates in the scroll view initially."
        )

        app.navigationBars.buttons["Add"].forceTapElement()
        app.buttons["Add New Template"].tap()

        XCTAssertEqual(
            app.scrollViews.buttons.count,
            1,
            "There should be 1 template in the scroll view."
        )

        app.scrollViews.buttons["New Template"].forceTapElement()
        app.navigationBars.buttons["Add"].forceTapElement()
        app.tables.cells.buttons["Bench"].tap()

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["Bench"].exists,
            "A section with a header matching the added exercise's should exist."
        )

        app.navigationBars.buttons["Home"].tap()

        XCTAssertEqual(
            app.scrollViews.buttons.count,
            1,
            "There should be 1 template in the scroll view."
        )

        XCTAssertTrue(
            app.scrollViews.buttons.staticTexts["1 exercise"].exists,
            "There should be 1 template in the scroll view with caption text reading '1 exercise'."
        )

        XCTAssertTrue(
            app.scrollViews.buttons.staticTexts["No sets"].exists,
            "There should be 1 template in the scroll view with caption text reading 'No sets'."
        )
    }

    func testAddingSetToExerciseInWorkout() {
        testAddingExerciseToWorkout()

        app.tables.cells.buttons["New Workout"].tap()

        app.tables.buttons["Add Set to Exercise: Bench"].tap()

        XCTAssertEqual(
            app.tables.children(matching: .cell).matching(identifier: "Close, Decrement, Increment").count,
            1,
            "There should be 1 set for the exercise."
         )

        app.navigationBars.buttons["Home"].tap()

        XCTAssertTrue(
            app.tables.buttons.staticTexts["1 exercise"].exists,
            "There should be 1 workout in the list with caption text reading '1 exercise'."
        )

        XCTAssertTrue(
            app.tables.buttons.staticTexts["1 set"].exists,
            "There should be 1 workout in the list with caption text reading '1 set'."
        )

        app.tabBars.buttons["Exercises"].tap()
        app.tables.cells.buttons["Bench"].tap()

        XCTAssertTrue(
            !app.tables.otherElements.staticTexts["Exercise History"].exists,
            "An exercise history should not yet exist for this exercise since no sets have been completed."
        )

        app.navigationBars.buttons["Exercises"].tap()
    }

    func testAddingSetToExerciseInTemplate() {
        testAddingExerciseToTemplate()

        app.scrollViews.buttons["New Template"].forceTapElement()

        app.tables.buttons["Add Set to Exercise: Bench"].tap()

        XCTAssertEqual(
            app.tables.children(matching: .cell).matching(identifier: "Close, Decrement, Increment").count,
            1,
            "There should be 1 set for the exercise."
        )

        app.navigationBars.buttons["Home"].tap()

        XCTAssertTrue(
            app.scrollViews.buttons.staticTexts["1 exercise"].exists,
            "There should be 1 template in the scroll view with caption text reading '1 exercise'."
        )

        XCTAssertTrue(
            app.scrollViews.buttons.staticTexts["1 set"].exists,
            "There should be 1 template in the scroll view with caption text reading '1 set'."
        )

        app.tabBars.buttons["Exercises"].tap()
        app.tables.cells.buttons["Bench"].tap()

        XCTAssertTrue(
            !app.tables.otherElements.staticTexts["Exercise History"].exists,
            "An exercise history should not yet exist for this exercise since no sets have been completed."
        )

        app.navigationBars.buttons["Exercises"].tap()
    }

    func testCompletingWorkoutMovesItToHistoryTab() {
        XCTAssertEqual(
            app.tables.cells.count,
            0,
            "There should be 0 workouts initially."
        )

        app.buttons["Add"].tap()
        app.buttons["Add New Workout"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            1,
            "There should be 1 workout in the list."
        )

        app.tables.cells.buttons["New Workout"].tap()
        app.tables.cells.buttons["Complete workout"].tap()

        XCTAssertTrue(
            app.alerts.element.exists,
            "An alert should be displayed after the user completes a workout."
        )

        XCTAssertEqual(
            app.alerts.element.label,
            "Workout Complete",
            "The alert title should read 'Workout Complete'."
        )

        app.alerts.buttons["OK"].tap()
        app.tabBars.buttons["Home"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            0,
            "There should be 0 workouts on the Home tab after the workout has been marked as completed."
        )

        app.tabBars.buttons["History"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            1,
            "There should be 1 workout on the History tab after the workout has been marked as completed."
        )
    }

    func testCreatingWorkoutFromTemplate() {
        testAddingSetToExerciseInTemplate()

        app.tabBars.buttons["Home"].tap()
        app.scrollViews.buttons["New Template"].forceTapElement()
        app.tables.buttons["Create workout from template"].tap()

        XCTAssertTrue(
            app.alerts.element.exists,
            "An alert should be displayed after the user taps to create a workout from a template."
        )

        XCTAssertEqual(
            app.alerts.element.label,
            "Create a workout?",
            "The alert title should read 'Create a workout?'."
        )

        app.alerts.buttons["Confirm"].tap()
        app.navigationBars.buttons["Home"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            1,
            "There should be 1 workouts in the list."
        )

        XCTAssertTrue(
            app.tables.buttons.staticTexts["1 exercise"].exists,
            "There should be 1 workout in the list with caption text reading '1 exercise'."
        )

        XCTAssertTrue(
            app.tables.buttons.staticTexts["1 set"].exists,
            "There should be 1 workout in the list with caption text reading '1 set'."
        )

        XCTAssertEqual(
            app.scrollViews.buttons.count,
            1,
            "There should be 1 template in the scroll view."
        )

        XCTAssertTrue(
            app.scrollViews.buttons.staticTexts["1 exercise"].exists,
            "There should be 1 template in the scroll view with caption text reading '1 exercise'."
        )

        XCTAssertTrue(
            app.scrollViews.buttons.staticTexts["1 set"].exists,
            "There should be 1 template in the scroll view with caption text reading '1 set'."
        )

        app.tabBars.buttons["Exercises"].tap()

        XCTAssertTrue(
            app.navigationBars.element.staticTexts["Exercises"].exists
        )

        app.tables.cells.buttons["Bench"].forceTapElement()

        XCTAssertTrue(
            !app.tables.otherElements.staticTexts["Exercise History"].exists,
            "An exercise history should not yet exist for this exercise since no sets have been completed."
        )
    }

    func testCreatingTemplateFromWorkout() {
        testAddingSetToExerciseInWorkout()

        app.tabBars.buttons["Home"].tap()
        app.tables.buttons["New Workout"].forceTapElement()
        app.tables.buttons["Create template from workout"].tap()

        XCTAssertTrue(
            app.alerts.element.exists,
            "An alert should be displayed after the user taps to create a template from a workout."
        )

        XCTAssertEqual(
            app.alerts.element.label,
            "Create a template?",
            "The alert title should read 'Create a template?'."
        )

        app.alerts.buttons["Confirm"].tap()
        app.navigationBars.buttons["Home"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            1,
            "There should be 1 workouts in the list."
        )

        XCTAssertTrue(
            app.tables.buttons.staticTexts["1 exercise"].exists,
            "There should be 1 workout in the list with caption text reading '1 exercise'."
        )

        XCTAssertTrue(
            app.tables.buttons.staticTexts["1 set"].exists,
            "There should be 1 workout in the list with caption text reading '1 set'."
        )

        XCTAssertEqual(
            app.scrollViews.buttons.count,
            1,
            "There should be 1 template in the scroll view."
        )

        XCTAssertTrue(
            app.scrollViews.buttons.staticTexts["1 exercise"].exists,
            "There should be 1 template in the scroll view with caption text reading '1 exercise'."
        )

        XCTAssertTrue(
            app.scrollViews.buttons.staticTexts["1 set"].exists,
            "There should be 1 template in the scroll view with caption text reading '1 set'."
        )

        app.tabBars.buttons["Exercises"].tap()

        XCTAssertTrue(
            app.navigationBars.element.staticTexts["Exercises"].exists
        )

        app.tables.cells.buttons["Bench"].forceTapElement()

        XCTAssertTrue(
            !app.tables.otherElements.staticTexts["Exercise History"].exists,
            "An exercise history should not yet exist for this exercise since no sets have been completed."
        )
    }

    func testDeletingWorkout() {
        XCTAssertEqual(
            app.tables.cells.count,
            0,
            "There should be 0 workouts initially."
        )

        app.buttons["Add"].tap()
        app.buttons["Add New Workout"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            1,
            "There should be 1 workout in the list."
        )

        app.tables.cells.buttons["New Workout"].tap()
        app.tables.cells.buttons["Delete workout"].tap()

        XCTAssertTrue(
            app.alerts.element.exists,
            "An alert should be displayed after the user taps to delete a workout."
        )

        XCTAssertEqual(
            app.alerts.element.label,
            "Are you sure?",
            "The alert title should read 'Are you sure?'."
        )

        app.alerts.buttons["Delete"].tap()
        app.tabBars.buttons["Home"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            0,
            "There should be 0 workouts in the list."
        )
    }

    func testDeletingTemplate() {
        XCTAssertEqual(
            app.scrollViews.buttons.count,
            0,
            "There should be 0 templates in the scroll view initially."
        )

        app.buttons["Add"].tap()
        app.buttons["Add New Template"].tap()

        XCTAssertEqual(
            app.scrollViews.buttons.count,
            1,
            "There should be 1 template in the scroll view."
        )

        app.scrollViews.buttons["New Template"].tap()
        app.tables.cells.buttons["Delete template"].tap()

        XCTAssertTrue(
            app.alerts.element.exists,
            "An alert should be displayed after the user taps to delete a template."
        )

        XCTAssertEqual(
            app.alerts.element.label,
            "Are you sure?",
            "The alert title should read 'Are you sure?'."
        )

        app.alerts.buttons["Delete"].tap()
        app.tabBars.buttons["Home"].tap()

        XCTAssertEqual(
            app.scrollViews.buttons.count,
            0,
            "There should be 0 templates in the scroll view."
        )
    }

    func testSwipeToDeleteWorkout() throws {
        try testHomeTabAddsWorkout()

        app.tables.cells.firstMatch.swipeLeft()
        app.tables.cells.firstMatch.buttons["Delete"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            4,
            "There should be four workouts remaining in the list."
        )
    }

    func testCompletingWorkoutExerciseSet() throws {
        testAddingSetToExerciseInWorkout()

        app.tabBars.buttons["Home"].tap()
        app.tables.cells.buttons["New Workout"].tap()

        app.tables.cells["Close, Decrement, Increment"].children(matching: .other).buttons.firstMatch.forceTapElement()

        XCTAssertTrue(
            app.tables.cells["100%, Progress"].staticTexts["100%"].exists,
            "1 of 1 exercises has been completed, therefore progress should be 100%."
        )

        app.navigationBars.buttons["Home"].tap()
        app.tabBars.buttons["Exercises"].tap()
        app.tables.cells.buttons["Bench"].tap()

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["Exercise History"].exists,
            "An exercise history should exist for this exercise since a set has been completed."
        )

        XCTAssertTrue(
            app.tables.cells.staticTexts["10 reps"].exists,
            "A row should exist in the exercise history with containing static text that reads '10 reps'."
        )

        app.navigationBars.buttons["Exercises"].tap()
    }

    func testIncreasingWorkoutExerciseSetReps() throws {
        try testCompletingWorkoutExerciseSet()

        app.tabBars.buttons["Home"].tap()
        app.tables.cells.buttons["New Workout"].tap()
        app.tables.steppers["10 reps"].buttons["Increment"].tap()

        app.navigationBars.buttons["Home"].tap()
        app.tabBars.buttons["Exercises"].tap()
        app.tables.cells.buttons["Bench"].tap()

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["Exercise History"].exists,
            "An exercise history should exist for this exercise since a set has been completed."
        )

        XCTAssertTrue(
            app.tables.cells.staticTexts["11 reps"].exists,
            "A row should exist in the exercise history with containing static text that reads '11 reps'."
        )

        app.navigationBars.buttons["Exercises"].tap()
    }

    func testRemovingExerciseFromWorkout() throws {
        try testCompletingWorkoutExerciseSet()

        app.tabBars.buttons["Home"].tap()
        app.tables.cells.buttons["New Workout"].tap()
        app.tables.cells.buttons["Remove exercise"].tap()

        XCTAssertTrue(
            app.alerts.element.exists,
            "An alert should be displayed after the user taps to remove an exercise."
        )

        XCTAssertEqual(
            app.alerts.element.label,
            "Are you sure?",
            "The alert title should read 'Are you sure?'."
        )

        app.alerts.buttons["Remove"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            5,
            "There should only be 5 cells in the list."
        )

        app.navigationBars.buttons["Home"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            1,
            "There should be 1 workout in the list."
        )

        XCTAssertTrue(
            app.tables.buttons.staticTexts["No exercises"].exists,
            "There should be 1 workout in the list with caption text reading 'No exercises'."
        )

        XCTAssertTrue(
            app.tables.buttons.staticTexts["No sets"].exists,
            "There should be 1 workout in the list with caption text reading 'No sets'."
        )

        app.tabBars.buttons["Exercises"].tap()
        app.tables.cells.buttons["Bench"].tap()

        XCTAssertTrue(
            !app.tables.otherElements.staticTexts["Exercise History"].exists,
            "An exercise history should not yet exist for this exercise since no sets have been completed."
        )
    }

    func testRenamingAnExercise() throws {
        testAddingExerciseToWorkout()

        app.tabBars.buttons["Exercises"].tap()
        app.tables.cells.buttons["Bench"].tap()
        app.textFields["Bench"].tap()

        XCTAssertTrue(
            app.keys["space"].waitForExistence(timeout: 1),
            "The keyboard must be visible on screen before being used."
        )

        app.keys["space"].tap()
        app.keys["more"].tap()
        app.keys["2"].tap()
        app.buttons["Return"].tap()

        app.tabBars.buttons["Home"].tap()
        app.tables.cells.buttons["New Workout"].tap()

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["Bench 2"].exists,
            "The exercise name should have been updated."
        )

        app.tabBars.buttons["Exercises"].tap()
        app.navigationBars.buttons["Exercises"].tap()

        XCTAssertTrue(
            app.tables.cells.buttons["Bench 2"].exists,
            "The exercise should be displayed with its new name."
        )

        app.tabBars.buttons["Home"].tap()
    }

    func testRegroupingAnExercise() throws {
        testAddingExerciseToWorkout()

        app.tabBars.buttons["Exercises"].tap()
        app.tables.cells.buttons["Bench"].tap()
        app.tables.cells.buttons["Muscle Group"].tap()
        app.tables.switches["Back"].tap()
        app.navigationBars.buttons["Exercises"].tap()
        app.tables.cells.buttons["Bench"].tap()

        XCTAssertTrue(
            app.tables.cells.buttons["MuscleGroup"].staticTexts[""].exists,
            "The exercise name should have been updated."
        )

        app.tabBars.buttons["Exercises"].tap()
        app.navigationBars.buttons["Exercises"].tap()

        XCTAssertTrue(
            app.tables.cells.buttons["Bench 2"].exists,
            "The exercise should be displayed with its new name."
        )

        app.tabBars.buttons["Home"].tap()
    }

// swiftlint:disable:next file_length
}
