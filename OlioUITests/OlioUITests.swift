//
//  OlioUITests.swift
//  OlioUITests
//
//  Created by Jake King on 04/12/2021.
//

import Foundation
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

    /// Tests that the app has three tabs; Home, History and Exercises.
    func testAppHasThreeTabs() throws {
        XCTAssertEqual(
            app.tabBars.buttons.count,
            3,
            "There should be 3 tabs in the app."
        )
    }

    /// Tests when the app is first launched that on the Home tab there are no workouts or templates and the correct
    /// buttons exist.
    func testHomeTabSetUp() throws {
        let addWorkoutButton = app.tables.cells.buttons["Add new workout"]
        let addTemplateButton = app.scrollViews.buttons["Add new template"]

        XCTAssertEqual(
            app.scrollViews.buttons.count,
            1,
            "There should be 1 template card in the scroll view initially."
        )

        XCTAssertTrue(
            addTemplateButton.exists,
            "The 1 template card that exists should contain the 'New Template' button."
        )

        XCTAssertEqual(
            app.tables.cells.count,
            1,
            "There should be 1 cell in the table initially."
        )

        XCTAssertTrue(
            addWorkoutButton.exists,
            "The 1 cell that exists should contain the 'New Workout' button."
        )
    }

    /// Tests when the app is first launched that on the History tab there are no workouts.
    func testHistoryTabSetUp() throws {
        app.tabBars.buttons["History"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            0,
            "There should be 0 cell in the table initially."
        )
    }

    /// Tests when the app is first launched that on the Exercises tab there are no exercises, the exercise category
    /// segmented control is not showing and the correct buttons are exist.
    func testExercisesTabSetUp() throws {
        app.tabBars.buttons["Exercises"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            0,
            "There should be 0 exercises in the list initially."
        )

        XCTAssertTrue(
            app.navigationBars.buttons["Add new exercise"].exists,
            "There should be a button to add a new exercise in the navigation bar."
        )

        XCTAssertTrue(
            app.buttons["Load exercise library"].exists,
            "When there are 0 exercises, 'Load exercise library' button should be visible for all exercise categories."
        )

        XCTAssertEqual(
            app.segmentedControls.count,
            0,
            "When there are 0 exercises, the exercise category segmented control should not be visible."
        )
    }

    /// Tests the "New Workout" button on the Home tab correctly adds a single workout scheduled for today.
    func testHomeTabAddsSingleWorkout() throws {
        let addWorkoutButton = app.tables.cells.buttons["Add new workout"]
        let todayButton = app.sheets.scrollViews.otherElements.buttons["Today"]
        let todayDate = Calendar.current.startOfDay(for: .now).formatted(date: .complete,
                                                                     time: .omitted)

        try testHomeTabSetUp()

        addWorkoutButton.tap()
        todayButton.tap()

        XCTAssertEqual(
            app.tables.cells.count,
            2,
            "There should be 1 workout, plus 1 cell containing the 'New Workout' button."
        )

        XCTAssertTrue(
            app.tables.staticTexts[todayDate].exists,
            "The section header should be today's date."
        )
    }

    /// Tests the "New Workout" button on the Home tab correctly adds workouts scheduled on multiple days.
    func testHomeTabAddsMultipleWorkouts() throws {
        let addWorkoutButton = app.tables.cells.buttons["Add new workout"]
        let todayButton = app.sheets.scrollViews.otherElements.buttons["Today"]
        let tomorrowButton = app.sheets.scrollViews.otherElements.buttons["Tomorrow"]
        let today = Calendar.current.startOfDay(for: .now).formatted(date: .complete,
                                                                     time: .omitted)
        let tomorrow = Calendar.current.startOfDay(for: .now.addingTimeInterval(86400)).formatted(date: .complete,
                                                                                                  time: .omitted)

        try testHomeTabSetUp()

        for workoutCount in 1...5 {
            XCTAssertTrue(
                addWorkoutButton.waitForExistence(timeout: 1),
                "The 'New Workout' button should exist before attempting to tap it."
            )

            addWorkoutButton.tap()

            if workoutCount.isMultiple(of: 2) {
                tomorrowButton.tap()
            } else {
                todayButton.tap()
            }

            XCTAssertEqual(
                app.tables.cells.count,
                workoutCount + 1,
                "There should be \(workoutCount) workout(s), plus 1 cell containing the 'New Workout' button."
            )

            XCTAssertTrue(
                app.tables.staticTexts[today].exists,
                "The section header should be today's date."
            )

            if workoutCount > 1 {
                XCTAssertTrue(
                    app.tables.staticTexts[tomorrow].exists,
                    "The section header should be tomorrow's date."
                )
            }
        }
    }

    /// Tests the "New Template" button on the Home tab correctly adds a single template.
    func testHomeTabAddsSingleTemplate() throws {
        let addTemplateButton = app.scrollViews.buttons["Add new template"]

        try testHomeTabSetUp()

        addTemplateButton.tap()

        XCTAssertEqual(
            app.scrollViews.buttons.count,
            2,
            "There should be 1 template, plus 1 cell containing the 'New Template' button."
        )
    }

    /// Tests the "New Template" button on the Home tab correct adds templates.
    func testHomeTabAddsMultipleTemplates() throws {
        let addTemplateButton = app.scrollViews.buttons["Add new template"]

        try testHomeTabSetUp()

        for templateCount in 1...5 {
            addTemplateButton.tap()

            XCTAssertEqual(
                app.scrollViews.buttons.count,
                templateCount + 1,
                "There should be \(templateCount) template(s), plus 1 cell containing the 'New Workout' button."
            )
        }
    }

    /// Tests editing the name of a workout results in an instant change and the new name being correctly displayed
    /// on the Home tab.
    func testEditingWorkoutName() throws {
        try testHomeTabAddsSingleWorkout()

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
            "The new workout name should be visible in the list of workouts."
        )
    }

    /// Tests editing the name of a template results in an instant change and the new name being correctly displayed
    /// on the Home tab.
    func testEditingTemplateName() throws {
        try testHomeTabAddsSingleTemplate()

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
            "The new template name should be visible in the list of templates."
        )
    }

    /// Tests editing the date of a workout results in an instant change and the new date being correct displayed on
    /// the Home tab.
    func testEditingWorkoutDate() throws {
        try testHomeTabAddsSingleWorkout()

        let tomorrow = Calendar.current.startOfDay(for: .now.addingTimeInterval(86400)).formatted(date: .complete,
                                                                                                  time: .omitted)
        let tomorrowText = app.tables.staticTexts[tomorrow]
        let tomorrowButton = app.sheets.scrollViews.otherElements.buttons["Tomorrow"]

        app.tables.cells.buttons["New Workout"].tap()
        app.tables.cells.buttons["Workout Date"].tap()
        tomorrowButton.tap()

        XCTAssertTrue(
            tomorrowText.waitForExistence(timeout: 1),
            "The section header should be tomorrow's date."
        )

        XCTAssertEqual(
            app.tables.cells.count,
            2,
            "There should be 1 workout, plus 1 cell containing the 'New Workout' button."
        )
    }

    /// Tests adding a single exercise results in that exercise being displayed in ExercisesView correctly and the
    /// 'Load exercise library' button disappearing.
    func testAddingAnExercise() throws {
        let exerciseCategories = ["Weights", "Body", "Cardio", "Class", "Stretch"]

        try testExercisesTabSetUp()

        app.navigationBars.buttons["Add new exercise"].tap()

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

        XCTAssertTrue(
            app.navigationBars.staticTexts["Exercises"].waitForExistence(timeout: 1),
            "The navigation bar title should be 'Exercises'."
        )

        XCTAssertEqual(
            app.tables.cells.count,
            1,
            "There should be 1 exercise in the list."
        )

        XCTAssertTrue(
            app.tables.cells.buttons["Bench"].exists,
            "The exercise that the user created should be available as a button in the list."
        )

        app.tables.cells.buttons["Bench"].tap()

        XCTAssertTrue(
            !app.tables.otherElements.staticTexts["Exercise History"].exists,
            "An exercise history should not yet exist for this exercise since no sets have been completed."
        )

        app.navigationBars.buttons["Exercises"].tap()

        XCTAssertEqual(
            app.segmentedControls.count,
            1,
            "When there is >= 1 exercises, the exercise category segmented control should be visible."
        )

        for category in exerciseCategories {
            app.segmentedControls.buttons[category].tap()

            XCTAssertTrue(
                !app.buttons["Load exercise library"].exists,
                "When there is >= 1 exercise(s) in any category, 'Load exercise library' button should not be visible."
            )
        }
    }

    /// Tests loading the exercise library results in the correct number of exercises being added to each category.
    func testLoadingExerciseLibrary() throws {
        // Also consider testing whether the muscle groups displayed are correct.
        let exerciseCategories = ["Weights", "Body", "Cardio", "Class", "Stretch"]

        try testExercisesTabSetUp()

        app.buttons["Load exercise library"].tap()

        XCTAssertEqual(
            app.segmentedControls.count,
            1,
            "When there is >= 1 exercises, the exercise category segmented control should be visible."
        )

        for category in exerciseCategories {
            app.segmentedControls.buttons[category].tap()

            XCTAssertTrue(
                !app.buttons["Load exercise library"].exists,
                "When there is >= 1 exercise(s) in any category, 'Load exercise library' button should not be visible."
            )

            if category == "Weights" {
                XCTAssertEqual(
                    app.tables.cells.count,
                    21,
                    "There should be 21 exercises in the list for the \(category) exercise category."
                )
            } else if category == "Body" {
                XCTAssertEqual(
                    app.tables.cells.count,
                    13,
                    "There should be 13 exercises in the list for the \(category) exercise category."
                )
            } else if category == "Cardio" {
                XCTAssertEqual(
                    app.tables.cells.count,
                    4,
                    "There should be 5 exercises in the list for the \(category) exercise category."
                )
            } else if category == "Class" {
                XCTAssertEqual(
                    app.tables.cells.count,
                    5,
                    "There should be 5 exercises in the list for the \(category) exercise category."
                )
            } else {
                XCTAssertEqual(
                    app.tables.cells.count,
                    9,
                    "There should be 13 exercises in the list for the \(category) exercise category."
                )
            }
        }
    }

    /// Tests adding an exercise results in the correct UI being displayed for both EditWorkoutView and on the Home tab.
    func testAddingExerciseToWorkout() throws {
        try testHomeTabAddsSingleWorkout()
        try testAddingAnExercise()

        app.tabBars.buttons["Home"].tap()
        app.tables.cells.buttons["New Workout"].tap()
        app.tables.cells.buttons["Add Exercise"].tap()
        app.tables.cells.otherElements["Bench"].tap()
        app.navigationBars.buttons["Add"].tap()

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["Bench"].exists,
            "A single cell with static text matching the added exercise's name should exist."
        )

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["Weights"].exists,
            "A single cell with static text matching the added exercise's category should exist."
        )

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["No sets"].exists,
            "A single cell with static text stating there are currently no sets for the exercise should exist."
        )

        XCTAssertTrue(
            !app.tables.otherElements.staticTexts["Completed"].exists,
            "Since there should be no sets for the exercise, there should be no mention of sets being completed."
        )

        XCTAssertEqual(
            app.tables.otherElements.progressIndicators.firstMatch.value as? String,
            "0%",
            "With no sets for the exercise none can be completed and the progress bar value should be 0%."
        )

        app.navigationBars.buttons["Home"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            2,
            "There should still only be 1 workout, plus the 'New Workout' button in the list."
        )

        XCTAssertTrue(
            app.tables.cells.staticTexts["1 exercise"].exists,
            "There should be 1 workout in the list with caption text reading '1 exercise'."
        )

        XCTAssertTrue(
            app.tables.cells.staticTexts["No sets"].exists,
            "There should be 1 workout in the list with caption text reading 'No sets'."
        )
    }

    /// Tests adding an exercise results in the correct UI being displayed for both EditWorkoutView and on the Home tab.
    func testAddingExerciseToTemplate() throws {
        try testHomeTabAddsSingleTemplate()
        try testAddingAnExercise()

        app.tabBars.buttons["Home"].tap()
        app.scrollViews.buttons["New Template"].tap()
        app.tables.cells.buttons["Add Exercise"].tap()
        app.tables.cells.otherElements["Bench"].tap()
        app.navigationBars.buttons["Add"].tap()

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["Bench"].exists,
            "A single cell with static text matching the added exercise's name should exist."
        )

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["Weights"].exists,
            "A single cell with static text matching the added exercise's category should exist."
        )

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["No sets"].exists,
            "A single cell with static text stating there are currently no sets for the exercise should exist."
        )

        XCTAssertTrue(
            !app.tables.otherElements.staticTexts["Completed"].exists,
            "Since there should be no sets for the exercise, there should be no mention of sets being completed."
        )

        XCTAssertTrue(
            !app.tables.otherElements.progressIndicators.firstMatch.exists,
            "There should be no progress bar for exercises in a template."
        )

        app.navigationBars.buttons["Home"].tap()

        XCTAssertEqual(
            app.scrollViews.buttons.count,
            2,
            "There should still only be 1 template, plus the 'New Template' button in the scroll view."
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

    /// Tests adding an exercise set to an exercise in a workout results in the correct UI being displayed for
    /// ExerciseSheetView, EditWorkoutView and EditExerciseView.
    // swiftlint:disable:next function_body_length
    func testAddingSetToExerciseInWorkout() throws {
        try testAddingExerciseToWorkout()

        app.tables.cells.buttons["New Workout"].tap()
        app.tables.cells["Bench, progress: 0%"].tap()

        XCTAssertTrue(
            !app.tables.cells["Set 1: 0 kilograms, 10 reps. Swipe right to complete, left to delete."].exists,
            "There should be 0 sets initially."
        )

        XCTAssertTrue(
            app.tables.buttons["Add Set to Exercise: Bench"].exists,
            "There should be 0 sets initially, plus the 'Add Set' button."
        )

        app.tables.buttons["Add Set to Exercise: Bench"].tap()

        XCTAssertEqual(
            app.tables.cells.firstMatch.otherElements.firstMatch.otherElements.count,
            2,
            "There should be 1 set, plus the 'Add Set'."
        )

        XCTAssertEqual(
            app.tables.cells.textFields["Weight"].value as? Double,
            nil,
            "The new set's weight should be nil."
        )

        XCTAssertEqual(
            app.tables.cells.textFields["Reps"].value as? Int,
            nil,
            "The new set's rep count should be nil."
        )

        app.navigationBars["Bench"].buttons["Save"].tap()

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["1 set, 0 completed"].exists,
            "A single cell with static text stating there is currently 1 incomplete set for the exercise should exist."
        )

        XCTAssertEqual(
            app.tables.otherElements.progressIndicators.firstMatch.value as? String,
            "0%",
            "The single exercise is incomplete and the progress bar value should therefore be 0%."
        )

        app.navigationBars.buttons["Home"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            2,
            "There should still only be 1 workout, plus the 'New Workout' button in the list."
        )

        XCTAssertTrue(
            app.tables.cells.staticTexts["1 exercise"].exists,
            "There should be 1 workout in the list with caption text reading '1 exercise'."
        )

        XCTAssertTrue(
            app.tables.cells.staticTexts["1 set"].exists,
            "There should be 1 workout in the list with caption text reading '1 set'."
        )

        app.tabBars.buttons["Exercises"].tap()
        app.segmentedControls.buttons["Weights"].tap()
        app.tables.cells.buttons["Bench"].tap()

        XCTAssertTrue(
            !app.tables.otherElements.staticTexts["Exercise History"].exists,
            "An exercise history should not yet exist for this exercise since no sets have been completed."
        )

        app.navigationBars.buttons["Exercises"].tap()
    }

    /// Tests adding an exercise set to an exercise in a template results in the correct UI being displayed for
    /// ExerciseSheetView, EditWorkoutView and EditExerciseView.
    // swiftlint:disable:next function_body_length
    func testAddingSetToExerciseInTemplate() throws {
        try testAddingExerciseToTemplate()

        app.scrollViews.buttons["New Template"].tap()

        app.tables.cells["Bench, progress: 0%"].tap()

        XCTAssertTrue(
            !app.tables.cells["Set 1: 0 kilograms, 10 reps. Swipe right to complete, left to delete."].exists,
            "There should be 0 sets initially."
        )

        XCTAssertTrue(
            app.tables.buttons["Add Set to Exercise: Bench"].exists,
            "There should be 0 sets initially, plus the 'Add Set' button."
        )

        app.tables.buttons["Add Set to Exercise: Bench"].tap()

        XCTAssertEqual(
            app.tables.cells.firstMatch.otherElements.firstMatch.otherElements.count,
            2,
            "There should be 1 set, plus the 'Add Set'."
        )

        XCTAssertEqual(
            app.tables.cells.textFields["Weight"].value as? Double,
            nil,
            "The new set's weight should be nil."
        )

        XCTAssertEqual(
            app.tables.cells.textFields["Reps"].value as? Int,
            nil,
            "The new set's rep count should be nil."
        )

        app.navigationBars["Bench"].buttons["Save"].tap()

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["1 set"].exists,
            "A single cell with static text stating there is currently 1 set for the exercise should exist."
        )

        app.navigationBars.buttons["Home"].tap()

        XCTAssertEqual(
            app.scrollViews.buttons.count,
            2,
            "There should still only be 1 template, plus the 'New Template' button in the scroll view."
        )

        XCTAssertTrue(
            app.scrollViews.buttons.staticTexts["1 exercise"].exists,
            "There should be 1 template in the scroll view with caption text reading '1 exercise'."
        )

        XCTAssertTrue(
            app.scrollViews.buttons.staticTexts["1 set"].exists,
            "There should be 1 template in the scroll view with caption text reading 'No sets'."
        )

        app.tabBars.buttons["Exercises"].tap()
        app.segmentedControls.buttons["Weights"].tap()
        app.tables.cells.buttons["Bench"].tap()

        XCTAssertTrue(
            !app.tables.otherElements.staticTexts["Exercise History"].exists,
            "An exercise history should not yet exist for this exercise since no sets have been completed."
        )

        app.navigationBars.buttons["Exercises"].tap()
    }

    /// Tests that using the 'Workout complete' button in EditWorkoutView displays an alert and then moves the workout
    /// to the History tab.
    func testCompletingWorkoutMovesItToHistoryTab() throws {
        try testHomeTabAddsSingleWorkout()

        app.tables.cells.buttons["New Workout"].tap()
        app.tables.cells.buttons["Workout complete"].tap()

        XCTAssertTrue(
            app.alerts.element.exists,
            "An alert should be displayed after the user completes a workout."
        )

        XCTAssertEqual(
            app.alerts.element.label,
            "Complete workout?",
            "The alert title should read 'Complete workout?'."
        )

        app.alerts.buttons["Confirm"].tap()

        XCTAssertTrue(
            app.tables.cells.buttons["Add Workout"].waitForExistence(timeout: 1),
            "The home screen should be visible prior to doing a count of the cells in the table."
        )

        XCTAssertEqual(
            app.tables.cells.count,
            1,
            "There should be 0 workouts, but 1 cell containing the 'New Workout' button after the workout is completed."
        )

        app.tabBars.buttons["History"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            1,
            "There should be 1 workout on the History tab after the workout is completed."
        )
    }

    /// Tests that using the 'Workout complete' button in EditWorkoutView displays an alert and then moves the workout
    /// to the History tab.
    func testSchedulingWorkoutMovesItToHomeTab() throws {
        try testCompletingWorkoutMovesItToHistoryTab()

        app.tables.cells.buttons["New Workout"].tap()
        app.tables.cells.buttons["Workout incomplete"].tap()

        XCTAssertTrue(
            app.alerts.element.exists,
            "An alert should be displayed after the user completes a workout."
        )

        XCTAssertEqual(
            app.alerts.element.label,
            "Not quite done?",
            "The alert title should read 'Not quite done?'."
        )

        app.alerts.buttons["Confirm"].tap()

        XCTAssertTrue(
            app.navigationBars.staticTexts["History"].waitForExistence(timeout: 1),
            "The history screen should be visible prior to doing a count of the cells in the table."
        )

        XCTAssertEqual(
            app.tables.cells.count,
            0,
            "There should be 0 workouts after the workout is scheduled."
        )

        app.tabBars.buttons["Home"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            2,
            "There should be 1 workout, plus 1 cell containing the 'New Workout' button after the workout is scheduled."
        )
    }

    /// Tests that using the 'Create workout' button for templates in EditWorkoutView adds a workout with the correct
    /// details.
    // swiftlint:disable:next function_body_length
    func testCreatingWorkoutFromTemplate() throws {
        try testAddingSetToExerciseInTemplate()
        let todayButton = app.sheets.scrollViews.otherElements.buttons["Today"]
        let todayDate = Calendar.current.startOfDay(for: .now).formatted(date: .complete,
                                                                     time: .omitted)

        app.tabBars.buttons["Home"].tap()
        app.scrollViews.buttons["New Template"].tap()
        app.tables.buttons["Create workout"].tap()

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
        todayButton.tap()
        app.navigationBars.buttons["Home"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            2,
            "There should be 1 workout, plus 1 cell containing the 'New Workout' button."
        )

        XCTAssertTrue(
            app.tables.staticTexts[todayDate].exists,
            "The section header should be today's date."
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
            2,
            "There should be 1 template, plus 1 cell containing the 'New Template' button."
        )

        XCTAssertTrue(
            app.scrollViews.buttons.staticTexts["1 exercise"].exists,
            "There should be 1 template in the scroll view with caption text reading '1 exercise'."
        )

        XCTAssertTrue(
            app.scrollViews.buttons.staticTexts["1 set"].exists,
            "There should be 1 template in the scroll view with caption text reading '1 set'."
        )

        app.tables.cells.buttons["New Workout (New Template)"].tap()

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["Bench"].exists,
            "A single cell with static text matching the added exercise's name should exist."
        )

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["Weights"].exists,
            "A single cell with static text matching the added exercise's category should exist."
        )

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["1 set, 0 completed"].exists,
            "A single cell with static text stating there is currently 1 incomplete set for the exercise should exist."
        )

        XCTAssertEqual(
            app.tables.otherElements.progressIndicators.firstMatch.value as? String,
            "0%",
            "With no sets for the exercise none can be completed and the progress bar value should be 0%."
        )

        app.navigationBars.buttons["Home"].tap()

        app.tabBars.buttons["Exercises"].tap()

        XCTAssertTrue(
            app.navigationBars.element.staticTexts["Exercises"].exists
        )

        app.tables.cells.buttons["Bench"].tap()

        XCTAssertTrue(
            !app.tables.otherElements.staticTexts["Exercise History"].exists,
            "An exercise history should not yet exist for this exercise since no sets have been completed."
        )
    }

    /// Tests that using the 'Make workout template' button for workouts in EditWorkoutView adds a template with the
    /// correct details.
    // swiftlint:disable:next function_body_length
    func testCreatingTemplateFromWorkout() throws {
        try testAddingSetToExerciseInWorkout()

        app.tabBars.buttons["Home"].tap()
        app.tables.cells.buttons["New Workout"].tap()
        app.tables.buttons["Make workout template"].tap()

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
            2,
            "There should be 1 workout, plus 1 cell containing the 'New Workout' button."
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
            2,
            "There should be 1 template, plus 1 cell containing the 'New Template' button."
        )

        XCTAssertTrue(
            app.scrollViews.buttons.staticTexts["1 exercise"].exists,
            "There should be 1 template in the scroll view with caption text reading '1 exercise'."
        )

        XCTAssertTrue(
            app.scrollViews.buttons.staticTexts["1 set"].exists,
            "There should be 1 template in the scroll view with caption text reading '1 set'."
        )

        app.scrollViews.buttons["New Template (New Workout)"].tap()

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["Bench"].exists,
            "A single cell with static text matching the added exercise's name should exist."
        )

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["Weights"].exists,
            "A single cell with static text matching the added exercise's category should exist."
        )

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["1 set"].exists,
            "A single cell with static text stating there is currently 1 set for the exercise should exist."
        )

        XCTAssertTrue(
            !app.tables.otherElements.staticTexts["Completed"].exists,
            "Since this is a template, there should be no mention of sets being completed."
        )

        XCTAssertTrue(
            !app.tables.otherElements.progressIndicators.firstMatch.exists,
            "There should be no progress bar for exercises in a template."
        )

        app.navigationBars.buttons["Home"].tap()
        app.tabBars.buttons["Exercises"].tap()

        XCTAssertTrue(
            app.navigationBars.element.staticTexts["Exercises"].exists
        )

        app.tables.cells.buttons["Bench"].tap()

        XCTAssertTrue(
            !app.tables.otherElements.staticTexts["Exercise History"].exists,
            "An exercise history should not yet exist for this exercise since no sets have been completed."
        )
    }

    /// Tests that the 'Delete Workout' button in EditWorkoutView deletes the workout and any exercise sets it
    /// contains, without deleting the exercise itself.
    func testDeletingWorkout() throws {
        try testAddingSetToExerciseInWorkout()

        app.tabBars.buttons["Home"].tap()

        XCTAssertTrue(
            app.tables.cells.buttons["New Workout"].waitForExistence(timeout: 1),
            "The 'New Workout' button should exist in the view before attempting to tap it."
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
            1,
            "There should be 0 workouts, plus 1 cell containing the 'New Workout' button."
        )

        app.tabBars.buttons["Exercises"].tap()
        app.tables.cells.buttons["Bench"].tap()

        XCTAssertTrue(
            !app.tables.otherElements.staticTexts["Exercise History"].exists,
            "An exercise history should not yet exist for this exercise since no sets have been completed."
        )
    }

    /// Tests that the 'Delete Workout' button in EditWorkoutView deletes the workout and any exercise sets it
    /// contains, without deleting the exercise itself.
    func testDeletingTemplate() throws {
        try testAddingSetToExerciseInTemplate()

        app.tabBars.buttons["Home"].tap()

        XCTAssertTrue(
            app.scrollViews.buttons["New Template"].waitForExistence(timeout: 1),
            "The 'New Template' button should exist in the view before attempting to tap it."
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
            1,
            "There should be 0 templates, plus 1 cell containing the 'New Template' button."
        )

        app.tabBars.buttons["Exercises"].tap()
        app.tables.cells.buttons["Bench"].tap()

        XCTAssertTrue(
            !app.tables.otherElements.staticTexts["Exercise History"].exists,
            "An exercise history should not yet exist for this exercise since no sets have been completed."
        )
    }

    /// Tests swipe to delete functionality of workouts on the home tab, ensuring it deletes the workout and any
    /// exercise sets it contains, without deleting the exercise itself.
    func testSwipeToDeleteWorkout() throws {
        try testAddingSetToExerciseInWorkout()
        app.tabBars.buttons["Home"].tap()

        let workoutToDelete = app.tables.cells.element(boundBy: 1)
        workoutToDelete.swipeLeft()
        workoutToDelete.buttons["Delete"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            1,
            "There should be 0 workouts, plus 1 cell containing the 'New Template' button."
        )

        app.tabBars.buttons["Exercises"].tap()
        app.tables.cells.buttons["Bench"].tap()

        XCTAssertTrue(
            !app.tables.otherElements.staticTexts["Exercise History"].exists,
            "An exercise history should not yet exist for this exercise since no sets have been completed."
        )
    }

    /// Tests that completing an ExerciseSet results in the correct UI being displayed on both EditWorkoutView and
    /// EditExerciseView.
    // swiftlint:disable:next function_body_length
    func testCompletingWorkoutExerciseSet() throws {
        try testAddingSetToExerciseInWorkout()
        let todayDate = Calendar.current.startOfDay(for: .now).formatted(date: .abbreviated,
                                                                     time: .omitted)
        let exerciseHistoryLabel = "New Workout, \(todayDate), 0.00kg, 10 reps"

        app.tabBars.buttons["Home"].tap()

        XCTAssertTrue(
            app.tables.cells.buttons["New Workout"].waitForExistence(timeout: 1),
            "The 'New Workout' button should exist in the view before attempting to tap it."
        )

        app.tables.cells.buttons["New Workout"].tap()
        app.tables.cells["Bench, progress: 0%"].tap()

        XCTAssertEqual(
            app.tables.cells.firstMatch.otherElements.firstMatch.otherElements.count,
            2,
            "There should be 1 set, plus the 'Add Set'."
        )

        XCTAssertTrue(
            app.tables.cells.firstMatch.otherElements.firstMatch.buttons["Mark set complete"].exists,
            "The set should initially be incomplete."
        )

        app.tables.cells.firstMatch.tap()

        XCTAssertTrue(
            app.tables.cells.firstMatch.otherElements.firstMatch.buttons["Mark set incomplete"].exists,
            "The set should now be complete."
        )

        app.navigationBars["Bench"].buttons["Save"].tap()

        XCTAssertTrue(
            app.tables.otherElements["Bench, progress: 100%"].exists,
            "The cell should now indicate that 100% of the exercise sets have been completed."
        )

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["1 set, 1 completed"].exists,
            "A single cell with static text stating there is currently 1 incomplete set for the exercise should exist."
        )

        XCTAssertEqual(
            app.tables.otherElements.progressIndicators.firstMatch.value as? String,
            "100%",
            "The single exercise is complete and the progress bar value should therefore be 100%."
        )

        app.navigationBars.buttons["Home"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            2,
            "There should still only be 1 workout, plus the 'New Workout' button in the list."
        )

        XCTAssertTrue(
            app.tables.cells.staticTexts["1 exercise"].exists,
            "There should be 1 workout in the list with caption text reading '1 exercise'."
        )

        XCTAssertTrue(
            app.tables.cells.staticTexts["1 set"].exists,
            "There should be 1 workout in the list with caption text reading '1 set'."
        )

        app.tabBars.buttons["Exercises"].tap()
        app.segmentedControls.buttons["Weights"].tap()
        app.tables.cells.buttons["Bench"].tap()

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["Exercise History"].exists,
            "An exercise history should exist for this exercise since no sets have been completed."
        )

        XCTAssertTrue(
            app.tables.otherElements[exerciseHistoryLabel].exists,
            "The exercise history should contain 1 set."
        )

        app.navigationBars.buttons["Exercises"].tap()
    }

    /// Tests increasing the rep count of an ExerciseSet results in the correct change in the exercise's history.
    func testIncreasingWorkoutExerciseSetReps() throws {
        try testCompletingWorkoutExerciseSet()

        app.tabBars.buttons["Home"].tap()
        app.tables.cells.buttons["New Workout"].tap()
        app.tables.cells["Bench, progress: 100%"].tap()
        app.tables.cells.firstMatch.textFields["Reps"].tap()
        app.keys["1"].tap()
        app.navigationBars.buttons["Save"].tap()
        app.navigationBars.buttons["Home"].tap()
        app.tabBars.buttons["Exercises"].tap()
        app.tables.cells.buttons["Bench"].tap()

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["Exercise History"].exists,
            "An exercise history should exist for this exercise since a set has been completed."
        )

        XCTAssertTrue(
            app.tables.cells.staticTexts["0.00kg, 101 reps"].exists,
            "A row should exist in the exercise history with containing static text that reads '101 reps'."
        )

        app.navigationBars.buttons["Exercises"].tap()
    }

    /// Tests that swipe to delete an exercise from a workout correctly updates the UI in EditWorkoutView, HomeView
    /// and EditExerciseView.
    func testSwipeToDeleteExerciseFromWorkout() throws {
        try testCompletingWorkoutExerciseSet()

        app.tabBars.buttons["Home"].tap()
        app.tables.cells.buttons["New Workout"].tap()
        app.tables.cells["Bench, progress: 100%"].swipeLeft()
        app.tables.cells.element(boundBy: 2).buttons["Delete"].tap()

        XCTAssertTrue(
            !app.tables.cells["Bench, progress: 0%"].exists,
            "The deleted exercise should no longer be visible in the workout."
        )

        app.navigationBars.buttons["Home"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            2,
            "There should still only be 1 workout, plus the 'New Workout' button in the list."
        )

        XCTAssertTrue(
            app.tables.cells.staticTexts["No exercises"].exists,
            "There should be 1 workout in the list with caption text reading 'No exercises'."
        )

        XCTAssertTrue(
            app.tables.cells.staticTexts["No sets"].exists,
            "There should be 1 workout in the list with caption text reading 'No sets'."
        )

        app.tabBars.buttons["Exercises"].tap()
        app.segmentedControls.buttons["Weights"].tap()
        app.tables.cells.buttons["Bench"].tap()

        XCTAssertTrue(
            !app.tables.otherElements.staticTexts["Exercise History"].exists,
            "An exercise history should not yet exist for this exercise since no sets have been completed."
        )

        app.navigationBars.buttons["Exercises"].tap()
    }

    /// Tests that swipe to add a set to an exercise in a workout correctly updates the UI in EditWorkoutView, HomeView
    /// and EditExerciseView.
    // swiftlint:disable:next function_body_length
    func testSwipeToAddSetToExerciseInWorkout() throws {
        try testCompletingWorkoutExerciseSet()
        let todayDate = Calendar.current.startOfDay(for: .now).formatted(date: .abbreviated,
                                                                     time: .omitted)
        let exerciseHistoryLabel = "New Workout, \(todayDate), 0.00kg, 10 reps"

        app.tabBars.buttons["Home"].tap()
        app.tables.cells.buttons["New Workout"].tap()
        app.tables.cells["Bench, progress: 100%"].swipeRight()
        app.tables.cells["Bench, progress: 100%"].buttons["Add set"].tap()

        XCTAssertTrue(
            app.tables.otherElements["Bench, progress: 50%"].exists,
            "The cell should now indicate that 50% of the exercise sets have been completed."
        )

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["2 sets, 1 completed"].exists,
            "A single cell with static text stating there are 2 sets with 1 completed for the exercise should exist."
        )

        XCTAssertEqual(
            app.tables.otherElements.progressIndicators.firstMatch.value as? String,
            "50%",
            "1 of the 2 sets for the exercise is completed and the progress bar value should therefore be 50%."
        )

        app.tables.cells["Bench, progress: 50%"].tap()

        XCTAssertEqual(
            app.tables.cells.firstMatch.otherElements.firstMatch.otherElements.count,
            2,
            "There should be 2 sets, plus the 'Add Set'."
        )

        XCTAssertEqual(
            app.tables.cells.element(boundBy: 1).textFields["Weight"].value as? Double,
            nil,
            "The new set's weight should be nil."
        )

        XCTAssertEqual(
            app.tables.cells.element(boundBy: 1).textFields["Reps"].value as? Int,
            nil,
            "The new set's rep count should be nil."
        )

        XCTAssertTrue(
            app.tables.cells.element(boundBy: 1).otherElements.firstMatch.buttons["Mark set complete"].exists,
            "The set should initially be incomplete."
        )

        app.navigationBars.buttons["Save"].tap()
        app.navigationBars.buttons["Home"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            2,
            "There should still only be 1 workout, plus the 'New Workout' button in the list."
        )

        XCTAssertTrue(
            app.tables.cells.staticTexts["1 exercise"].exists,
            "There should be 1 workout in the list with caption text reading '1 exercise'."
        )

        XCTAssertTrue(
            app.tables.cells.staticTexts["2 sets"].exists,
            "There should be 1 workout in the list with caption text reading '2 set'."
        )

        app.tabBars.buttons["Exercises"].tap()
        app.segmentedControls.buttons["Weights"].tap()
        app.tables.cells.buttons["Bench"].tap()

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["Exercise History"].exists,
            "An exercise history should exist for this exercise since sets have been completed."
        )

        XCTAssertTrue(
            app.tables.otherElements[exerciseHistoryLabel].exists,
            "The exercise history should contain 1 set."
        )

        app.navigationBars.buttons["Exercises"].tap()
    }

    /// Tests that swipe to complete the next for an exercise in a workout correctly updates the UI in EditWorkoutView,
    /// HomeView and EditExerciseView.
    // swiftlint:disable:next function_body_length
    func testSwipeToCompleteNextSetIncompleteSetInWorkout() throws {
        try testAddingSetToExerciseInWorkout()
        let todayDate = Calendar.current.startOfDay(for: .now).formatted(date: .abbreviated,
                                                                     time: .omitted)
        let exerciseHistoryLabel = "New Workout, \(todayDate), 0.00kg, 10 reps"

        app.tabBars.buttons["Home"].tap()
        app.tables.cells.buttons["New Workout"].tap()
        app.tables.cells["Bench, progress: 0%"].tap()
        app.tables.cells.buttons["Add set"].tap()
        app.navigationBars.buttons["Save"].tap()

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["2 sets, 0 completed"].exists,
            "A single cell with static text stating there are 2 incomplete sets for the exercise should exist."
        )

        XCTAssertEqual(
            app.tables.otherElements.progressIndicators.firstMatch.value as? String,
            "0%",
            "The single exercise is incomplete and the progress bar value should therefore be 0%."
        )

        app.tables.cells["Bench, progress: 0%"].swipeRight()
        app.tables.cells["Bench, progress: 0%"].buttons["Complete next set"].tap()

        XCTAssertTrue(
            app.tables.otherElements["Bench, progress: 50%"].exists,
            "The cell should now indicate that 50% of the exercise sets have been completed."
        )

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["2 sets, 1 completed"].exists,
            "A single cell with static text stating there are 2 sets with 1 completed for the exercise should exist."
        )

        XCTAssertEqual(
            app.tables.otherElements.progressIndicators.firstMatch.value as? String,
            "50%",
            "1 of the 2 sets for the exercise is complete and the progress bar value should therefore be 50%."
        )

        app.tables.cells["Bench, progress: 50%"].tap()

        XCTAssertTrue(
            app.tables.cells.element(boundBy: 0).otherElements.firstMatch.buttons["Mark set incomplete"].exists,
            "The completed set should have the option to be marked incomplete."
        )

        XCTAssertTrue(
            app.tables.cells.element(boundBy: 1).otherElements.firstMatch.buttons["Mark set complete"].exists,
            "The other set should have the option to be marked complete."
        )

        app.navigationBars.buttons["Save"].tap()
        app.navigationBars.buttons["Home"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            2,
            "There should still only be 1 workout, plus the 'New Workout' button in the list."
        )

        XCTAssertTrue(
            app.tables.cells.staticTexts["1 exercise"].exists,
            "There should be 1 workout in the list with caption text reading '1 exercise'."
        )

        XCTAssertTrue(
            app.tables.cells.staticTexts["2 sets"].exists,
            "There should be 1 workout in the list with caption text reading '2 set'."
        )

        app.tabBars.buttons["Exercises"].tap()
        app.segmentedControls.buttons["Weights"].tap()
        app.tables.cells.buttons["Bench"].tap()

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["Exercise History"].exists,
            "An exercise history should exist for this exercise since sets have been completed."
        )

        XCTAssertTrue(
            app.tables.otherElements[exerciseHistoryLabel].exists,
            "The exercise history should contain 1 set."
        )

        app.navigationBars.buttons["Exercises"].tap()
    }

    /// Tests that swipe to delete an exercise set for an exercise from a workout correctly updates the UI in
    /// ExerciseSheetView, EditWorkoutView, HomeView and EditExerciseView.
    func testSwipeToDeleteExerciseSetFromWorkoutExercise() throws {
        try testCompletingWorkoutExerciseSet()

        // swiftlint:disable:next line_length
        let setToDelete = app.tables.otherElements["Set 1: 0.0 kilograms, 10 reps. Swipe right to complete, left to delete."]

        app.tabBars.buttons["Home"].tap()
        app.tables.cells.buttons["New Workout"].tap()
        app.tables.cells["Bench, progress: 100%"].tap()
        setToDelete.swipeLeft()
        app.tables.cells.buttons["Delete"].tap()

        app.navigationBars["Bench"].buttons["Save"].tap()

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["No sets"].exists,
            "A single cell with static text stating there are no sets for the exercise should exist."
        )

        XCTAssertEqual(
            app.tables.otherElements.progressIndicators.firstMatch.value as? String,
            "0%",
            "The single exercise has no sets and the progress bar value should therefore be 0%."
        )

        app.navigationBars.buttons["Home"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            2,
            "There should still only be 1 workout, plus the 'New Workout' button in the list."
        )

        XCTAssertTrue(
            app.tables.cells.staticTexts["1 exercise"].exists,
            "There should be 1 workout in the list with caption text reading '1 exercise'."
        )

        XCTAssertTrue(
            app.tables.cells.staticTexts["No sets"].exists,
            "There should be 1 workout in the list with caption text reading 'No sets'."
        )

        app.tabBars.buttons["Exercises"].tap()
        app.segmentedControls.buttons["Weights"].tap()
        app.tables.cells.buttons["Bench"].tap()

        XCTAssertTrue(
            !app.tables.otherElements.staticTexts["Exercise History"].exists,
            "An exercise history should not yet exist for this exercise since no sets have been completed."
        )

        app.navigationBars.buttons["Exercises"].tap()
    }

    /// Tests that swiping to delete an exercise correctly updates the UI in EditWorkoutView, HomeView and
    /// EditExerciseView.
    func testSwipeToDeleteExercise() throws {
        try testAddingExerciseToWorkout()

        app.tabBars.buttons["Exercises"].tap()
        app.segmentedControls.buttons["Weights"].tap()
        app.tables.cells.buttons["Bench"].swipeLeft()
        app.tables.buttons["Delete"].tap()

        try testExercisesTabSetUp()

        app.tabBars.buttons["Home"].tap()

        XCTAssertTrue(
            app.tables.cells.staticTexts["No exercises"].exists,
            "There should be 1 workout in the list with caption text reading 'No exercises'."
        )

        XCTAssertTrue(
            app.tables.cells.staticTexts["No sets"].exists,
            "There should be 1 workout in the list with caption text reading 'No sets'."
        )

        app.tables.cells.buttons["New Workout"].tap()

        XCTAssertTrue(
            !app.tables.otherElements["Bench, progress: 100%"].exists,
            "There should now be no cell indicating the existence of the deleted exercise."
        )
    }

    /// Tests deleting an exercise correctly updates the UI in ExercisesView, HomeView and EditWorkoutView.
    func testDeletingAnExercise() throws {
        try testAddingExerciseToWorkout()

        app.tabBars.buttons["Exercises"].tap()
        app.segmentedControls.buttons["Weights"].tap()
        app.tables.cells.buttons["Bench"].tap()
        app.navigationBars.buttons["Delete"].tap()

        XCTAssertTrue(
            app.alerts.element.exists,
            "An alert should be displayed after the user taps to delete an exercise."
        )

        XCTAssertEqual(
            app.alerts.element.label,
            "Are you sure?",
            "The alert title should read 'Are you sure?'."
        )

        app.alerts.buttons["Delete"].tap()

        XCTAssertTrue(
            app.navigationBars["Exercises"].waitForExistence(timeout: 1),
            "Ensure the user has been popped from the previous navigation link destination."
        )
        XCTAssertEqual(
            app.tables.cells.count,
            0,
            "There should be 0 exercises in the list."
        )

        app.tabBars.buttons["Home"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            2,
            "There should be 1 workout, plus 1 cell containing the 'New Workout' button."
        )

        XCTAssertTrue(
            app.tables.cells.staticTexts["No exercises"].exists,
            "There should be 1 workout in the list with caption text reading 'No exercises'."
        )

        XCTAssertTrue(
            app.tables.cells.staticTexts["No sets"].exists,
            "There should be 1 workout in the list with caption text reading 'No sets'."
        )

        app.tables.cells.buttons["New Workout"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            6,
            "There should be 6 cells visible in the table."
        )

        XCTAssertTrue(
            !app.tables.otherElements["Bench, progress: 100%"].exists,
            "There should now be no cell indicating the existence of the deleted exercise."
        )
    }

    /// Tests that renaming an exercise correctly updates the UI in ExercisesView and EditWorkoutView.
    func testRenamingAnExercise() throws {
        try testAddingExerciseToWorkout()

        app.tabBars.buttons["Exercises"].tap()
        app.segmentedControls.buttons["Weights"].tap()
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
        app.tables.cells.buttons["Save Changes"].tap()
        app.navigationBars.buttons["Exercises"].tap()
        app.tabBars.buttons["Home"].tap()
        app.tables.cells.buttons["New Workout"].tap()

        XCTAssertTrue(
            app.tables.otherElements.staticTexts["Bench 2"].exists,
            "The exercise name should have been updated."
        )

        app.tabBars.buttons["Exercises"].tap()

        XCTAssertTrue(
            app.tables.cells.buttons["Bench 2"].exists,
            "The exercise should be displayed with its new name."
        )

        app.tabBars.buttons["Home"].tap()
    }

    /// Tests that when an exercise's muscle group is changed the UI correctly updates in ExercisesView and
    /// EditExerciseView.
    func testRegroupingAnExercise() throws {
        try testAddingExerciseToWorkout()

        app.tabBars.buttons["Exercises"].tap()
        app.segmentedControls.buttons["Weights"].tap()
        app.tables.cells.buttons["Bench"].tap()
        app.tables.cells.buttons["Muscle Group"].tap()
        app.tables.switches["Back"].tap()
        app.tables.cells.buttons["Save Changes"].tap()
        app.navigationBars.buttons["Exercises"].tap()

        XCTAssertTrue(
            app.tables.staticTexts["Back"].exists,
            "The exercise name should have been updated."
        )

        app.tables.cells.buttons["Bench"].tap()

        XCTAssertEqual(
            app.tables.cells.buttons["Muscle Group"].value as? String ?? "",
            "Back",
            "The exercise muscle group should have been updated."
        )

        app.navigationBars.buttons["Exercises"].tap()
        app.tabBars.buttons["Home"].tap()
    }

    /// Tests that when an exercise's category is changed the UI correctly updates in ExercisesView and
    /// EditExerciseView.
    func testRecategorisingAnExercise() throws {
        try testAddingExerciseToWorkout()

        app.tabBars.buttons["Exercises"].tap()
        app.segmentedControls.buttons["Weights"].tap()
        app.tables.cells.buttons["Bench"].tap()
        app.tables.cells.buttons["Exercise Category"].tap()
        app.tables.switches["Body"].tap()
        app.tables.cells.buttons["Save Changes"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            0,
            "The exercise category changed and no exercises should be visible in the 'Weights' category."
        )

        app.segmentedControls.buttons["Body"].tap()

        XCTAssertTrue(
            app.tables.cells.buttons["Bench"].exists,
            "The exercise category changed and 'Bench' should now be visible in the 'Body' category."
        )

        XCTAssertEqual(
            app.tables.cells.count,
            1,
            "There should be no other exercises visible in the 'Body' category."
        )

        app.tables.cells.buttons["Bench"].tap()

        XCTAssertEqual(
            app.tables.cells.buttons["Exercise Category"].value as? String ?? "",
            "Body",
            "The exercise category should have been updated."
        )
        app.navigationBars.buttons["Exercises"].tap()
        app.tabBars.buttons["Home"].tap()
        app.tables.cells.buttons["New Workout"].tap()

        XCTAssertTrue(
            app.tables.cells["Bench, progress: 0%"].exists,
            "The 'Bench' exercise should still exist and be visible in the workout."
        )

        XCTAssertEqual(
            app.tables.cells.count,
            7,
            "There should be 7 cells visible in the table."
        )

        XCTAssertTrue(
            app.tables.cells["Bench, progress: 0%"].staticTexts["Body"].exists,
            "The exercise category text should have been updated."
        )
    }

    /// Tests that the updating of a template's name does not result in any change to the name of a workout
    /// created from that template.
    func testEditingTemplateNameIndependentOfWorkout() throws {
        try testCreatingWorkoutFromTemplate()

        app.navigationBars.buttons["Exercises"].tap()
        app.tabBars.buttons["Home"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            2,
            "There should only be 1 workout, plus the 'New Workout' button in the list."
        )

        XCTAssertTrue(
            app.tables.cells.staticTexts["New Workout (New Template)"].exists,
            "There should be 1 workout in the list with caption text reading '1 exercise'."
        )

        app.scrollViews.buttons["New Template"].tap()
        app.textFields["New Template"].tap()
        app.keys["space"].tap()
        app.keys["more"].tap()
        app.keys["2"].tap()
        app.buttons["Return"].tap()
        app.navigationBars.buttons["Home"].tap()

        XCTAssertTrue(
            app.scrollViews.buttons["New Template 2"].exists,
            "The new template name should be visible in the list of templates."
        )

        XCTAssertTrue(
            app.tables.cells.buttons["New Workout (New Template)"].exists,
            "The workout name should have remained the same despite the template name changing."
        )

        XCTAssertTrue(
            !app.tables.cells.buttons["New Template 2"].exists,
            "No new workouts should have been created as a result of the template name change."
        )
    }

    /// Tests that the removal of a template's exercise does not result in any change to the exercises of a workout
    /// created from that template.
    func testRemovingTemplateExercisesIndependentOfWorkout() throws {
        try testCreatingWorkoutFromTemplate()

        app.navigationBars.buttons["Exercises"].tap()
        app.tabBars.buttons["Home"].tap()

        XCTAssertEqual(
            app.tables.cells.count,
            2,
            "There should only be 1 workout, plus the 'New Workout' button in the list."
        )

        XCTAssertTrue(
            app.tables.cells.staticTexts["New Workout (New Template)"].exists,
            "There should be 1 workout in the list with caption text reading '1 exercise'."
        )

        app.scrollViews.buttons["New Template"].tap()
        app.tables.cells["Bench, progress: 100%"].swipeLeft()
        app.tables.cells.element(boundBy: 2).buttons["Delete"].tap()

        XCTAssertTrue(
            !app.tables.cells["Bench, progress: 0%"].exists,
            "The deleted exercise should no longer be visible in the workout."
        )

        app.navigationBars.buttons["Home"].tap()

        XCTAssertTrue(
            app.scrollViews.buttons["New Template"].staticTexts["No exercises"].exists,
            "The template should contain no exercises."
        )

        XCTAssertTrue(
            app.scrollViews.buttons["New Template"].staticTexts["No sets"].exists,
            "The template should contain no sets."
        )

        XCTAssertTrue(
            app.tables.cells.buttons["New Workout (New Template)"].staticTexts["1 exercise"].exists,
            "The workout created from the template should have 1 exercise"
        )

        XCTAssertTrue(
            app.tables.cells.buttons["New Workout (New Template)"].staticTexts["1 set"].exists,
            "The workout created from the template should have 1 set"
        )

        app.tables.cells.buttons["New Workout (New Template)"].tap()

        XCTAssertTrue(
            !app.tables.cells["Bench, progress: 0%"].exists,
            "The deleted exercise should no longer be visible in the workout."
        )
    }

    /// Tests that the updating of a template's exercise sets does not result in any change to the sets of a workout
    /// created from that template.
    func testEditingTemplateExerciseSetIndependentOfWorkout() throws {
        try testCreatingWorkoutFromTemplate()

        app.navigationBars.buttons["Exercises"].tap()
        app.tabBars.buttons["Home"].tap()
        app.scrollViews.buttons["New Template"].tap()
        app.tables.cells["Bench, progress: 0%"].tap()
        app.tables.cells.firstMatch.textFields["Reps"].tap()
        app.keys["1"].tap()
        app.navigationBars.buttons["Save"].tap()
        app.navigationBars.buttons["Home"].tap()
        app.tables.cells.buttons["New Workout (New Template)"].tap()
        app.tables.cells["Bench, progress: 0%"].tap()

        XCTAssertEqual(
            app.tables.cells.firstMatch.textFields["Reps"].value as? String ?? "",
            "10",
            "The rep count for the exercise in the workout should not have changed."
        )
    }
// swiftlint:disable:next file_length
}
