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
            app.tables.otherElements.progressIndicators.firstMatch.value as? Int,
            nil,
            "With no sets for the exercise none can be completed and the progress bar value should be 0."
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
            app.tables.otherElements.progressIndicators.firstMatch.value as? Int,
            nil,
            "The single exercise is incomplete and the progress bar value should therefore be 0."
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
            app.tables.otherElements.progressIndicators.firstMatch.value as? Int,
            nil,
            "With no sets for the exercise none can be completed and the progress bar value should be 0."
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
//
//    func testDeletingWorkout() {
//        XCTAssertEqual(
//            app.tables.cells.count,
//            0,
//            "There should be 0 workouts initially."
//        )
//
//        app.buttons["Add"].tap()
//        app.buttons["Add New Workout"].tap()
//
//        XCTAssertEqual(
//            app.tables.cells.count,
//            1,
//            "There should be 1 workout in the list."
//        )
//
//        XCTAssertTrue(
//            app.tables.cells.buttons["New Workout"].waitForExistence(timeout: 1),
//            "The 'New Workout' button should exist in the view before attempting to tap it."
//        )
//
//        app.tables.cells.buttons["New Workout"].tap()
//        app.tables.cells.buttons["Delete workout"].tap()
//
//        XCTAssertTrue(
//            app.alerts.element.exists,
//            "An alert should be displayed after the user taps to delete a workout."
//        )
//
//        XCTAssertEqual(
//            app.alerts.element.label,
//            "Are you sure?",
//            "The alert title should read 'Are you sure?'."
//        )
//
//        app.alerts.buttons["Delete"].tap()
//        app.tabBars.buttons["Home"].tap()
//
//        XCTAssertEqual(
//            app.tables.cells.count,
//            0,
//            "There should be 0 workouts in the list."
//        )
//    }
//
//    func testDeletingTemplate() {
//        XCTAssertEqual(
//            app.scrollViews.buttons.count,
//            0,
//            "There should be 0 templates in the scroll view initially."
//        )
//
//        app.buttons["Add"].tap()
//        app.buttons["Add New Template"].tap()
//
//        XCTAssertEqual(
//            app.scrollViews.buttons.count,
//            1,
//            "There should be 1 template in the scroll view."
//        )
//
//        XCTAssertTrue(
//            app.scrollViews.buttons["New Template"].waitForExistence(timeout: 1),
//            "The 'New Template' button should exist in the view before attempting to tap it."
//        )
//
//        app.scrollViews.buttons["New Template"].tap()
//        app.tables.cells.buttons["Delete template"].tap()
//
//        XCTAssertTrue(
//            app.alerts.element.exists,
//            "An alert should be displayed after the user taps to delete a template."
//        )
//
//        XCTAssertEqual(
//            app.alerts.element.label,
//            "Are you sure?",
//            "The alert title should read 'Are you sure?'."
//        )
//
//        app.alerts.buttons["Delete"].tap()
//        app.tabBars.buttons["Home"].tap()
//
//        XCTAssertEqual(
//            app.scrollViews.buttons.count,
//            0,
//            "There should be 0 templates in the scroll view."
//        )
//    }
//
//    func testSwipeToDeleteWorkout() throws {
//        try testHomeTabAddsMultipleWorkouts()
//
//        app.tables.cells.firstMatch.swipeLeft()
//        app.tables.cells.firstMatch.buttons["Delete"].tap()
//
//        XCTAssertEqual(
//            app.tables.cells.count,
//            4,
//            "There should be four workouts remaining in the list."
//        )
//    }
//
//    func testCompletingWorkoutExerciseSet() throws {
//        try testAddingSetToExerciseInWorkout()
//
//        app.tabBars.buttons["Home"].tap()
//
//        XCTAssertTrue(
//            app.tables.cells.buttons["New Workout"].waitForExistence(timeout: 1),
//            "The 'New Workout' button should exist in the view before attempting to tap it."
//        )
//
//        app.tables.cells.buttons["New Workout"].forceTapElement()
//
//        // swiftlint:disable:next line_length
//        app.tables.cells["10 reps. Mark set complete, Decrement, Increment"].children(matching: .other).buttons.firstMatch.forceTapElement()
//
//        XCTAssertTrue(
//            app.tables.cells["Progress: 100%"].exists,
//            "1 of 1 exercises has been completed, therefore progress should be 100%."
//        )
//
//        app.navigationBars.buttons["Home"].tap()
//        app.tabBars.buttons["Exercises"].tap()
//        app.tables.cells.buttons["Bench"].tap()
//
//        XCTAssertTrue(
//            app.tables.otherElements.staticTexts["Exercise History"].exists,
//            "An exercise history should exist for this exercise since a set has been completed."
//        )
//
//        XCTAssertTrue(
//            app.tables.cells.staticTexts["10 reps"].exists,
//            "A row should exist in the exercise history with containing static text that reads '10 reps'."
//        )
//
//        app.navigationBars.buttons["Exercises"].tap()
//    }
//
//    func testIncreasingWorkoutExerciseSetReps() throws {
//        try testCompletingWorkoutExerciseSet()
//
//        app.tabBars.buttons["Home"].tap()
//        app.tables.cells.buttons["New Workout"].tap()
//        app.tables.steppers["10 reps"].buttons["Increment"].tap()
//
//        app.navigationBars.buttons["Home"].tap()
//        app.tabBars.buttons["Exercises"].tap()
//        app.tables.cells.buttons["Bench"].tap()
//
//        XCTAssertTrue(
//            app.tables.otherElements.staticTexts["Exercise History"].exists,
//            "An exercise history should exist for this exercise since a set has been completed."
//        )
//
//        XCTAssertTrue(
//            app.tables.cells.staticTexts["11 reps"].exists,
//            "A row should exist in the exercise history with containing static text that reads '11 reps'."
//        )
//
//        app.navigationBars.buttons["Exercises"].tap()
//    }
//
//    func testRemovingExerciseFromWorkout() throws {
//        try testCompletingWorkoutExerciseSet()
//
//        app.tabBars.buttons["Home"].tap()
//        app.tables.cells.buttons["New Workout"].tap()
//        app.tables.cells.buttons["Remove exercise"].tap()
//
//        XCTAssertTrue(
//            app.alerts.element.exists,
//            "An alert should be displayed after the user taps to remove an exercise."
//        )
//
//        XCTAssertEqual(
//            app.alerts.element.label,
//            "Are you sure?",
//            "The alert title should read 'Are you sure?'."
//        )
//
//        app.alerts.buttons["Remove"].tap()
//
//        XCTAssertEqual(
//            app.tables.cells.count,
//            5,
//            "There should only be 5 cells in the list."
//        )
//
//        app.navigationBars.buttons["Home"].tap()
//
//        XCTAssertEqual(
//            app.tables.cells.count,
//            1,
//            "There should be 1 workout in the list."
//        )
//
//        XCTAssertTrue(
//            app.tables.buttons.staticTexts["No exercises"].exists,
//            "There should be 1 workout in the list with caption text reading 'No exercises'."
//        )
//
//        XCTAssertTrue(
//            app.tables.buttons.staticTexts["No sets"].exists,
//            "There should be 1 workout in the list with caption text reading 'No sets'."
//        )
//
//        app.tabBars.buttons["Exercises"].tap()
//        app.tables.cells.buttons["Bench"].tap()
//
//        XCTAssertTrue(
//            !app.tables.otherElements.staticTexts["Exercise History"].exists,
//            "An exercise history should not yet exist for this exercise since no sets have been completed."
//        )
//    }
//
//    func testRenamingAnExercise() throws {
//        try testAddingExerciseToWorkout()
//
//        app.tabBars.buttons["Exercises"].tap()
//        app.tables.cells.buttons["Bench"].tap()
//        app.textFields["Bench"].tap()
//
//        XCTAssertTrue(
//            app.keys["space"].waitForExistence(timeout: 1),
//            "The keyboard must be visible on screen before being used."
//        )
//
//        app.keys["space"].tap()
//        app.keys["more"].tap()
//        app.keys["2"].tap()
//        app.buttons["Return"].tap()
//
//        app.tabBars.buttons["Home"].tap()
//        app.tables.cells.buttons["New Workout"].tap()
//
//        XCTAssertTrue(
//            app.tables.otherElements.staticTexts["Bench 2"].exists,
//            "The exercise name should have been updated."
//        )
//
//        app.tabBars.buttons["Exercises"].tap()
//        app.navigationBars.buttons["Exercises"].tap()
//
//        XCTAssertTrue(
//            app.tables.cells.buttons["Bench 2"].exists,
//            "The exercise should be displayed with its new name."
//        )
//
//        app.tabBars.buttons["Home"].tap()
//    }
//
//    func testRegroupingAnExercise() throws {
//        try testAddingExerciseToWorkout()
//
//        app.tabBars.buttons["Exercises"].tap()
//        app.tables.cells.buttons["Bench"].tap()
//        app.tables.cells.buttons["Muscle Group"].tap()
//        app.tables.switches["Back"].tap()
//        app.navigationBars.buttons["Exercises"].tap()
//        app.tables.cells.buttons["Bench"].tap()
//
//        XCTAssertEqual(
//            app.tables.cells.buttons["Muscle Group"].value as? String ?? "",
//            "Back",
//            "The exercise name should have been updated."
//        )
//
//        app.navigationBars.buttons["Exercises"].tap()
//        app.tabBars.buttons["Home"].tap()
//    }
//
//    func testSwipeToDeleteExerciseSetFromWorkoutExercise() throws {
//        app.navigationBars.buttons["Sample Data"].tap()
//
//        XCTAssertTrue(
//            app.tables.buttons.firstMatch.staticTexts["1 exercise"].exists,
//            "There should be 2 workouts in the list and the first should have caption text reading '1 exercise'."
//        )
//
//        XCTAssertTrue(
//            app.tables.cells.staticTexts["3 sets"].exists,
//            "There should be 2 workouts in the list and the first should have caption text reading '3 sets'."
//        )
//
//        app.tables.cells.buttons["Workout - 3"].tap()
//
//        XCTAssertTrue(
//            app.tables.cells["1 rep. Mark set incomplete, Decrement, Increment"].waitForExistence(timeout: 1),
//            "The exercise set cell should be visible on screen."
//        )
//
//        XCTAssertEqual(
//            app.tables.cells.matching(identifier: "1 rep. Mark set incomplete, Decrement, Increment").count,
//            1,
//            "There should be exactly one completed workout."
//        )
//
//        app.swipeUp()
//        // swiftlint:disable:next line_length
//        app.tables.cells["1 rep. Mark set incomplete, Decrement, Increment"].children(matching: .other).firstMatch.swipeLeft()
//        app.tables.cells.buttons["Delete"].tap()
//
//        XCTAssertEqual(
//            app.tables.cells.matching(identifier: "Selected, Decrement, Increment").count,
//            0,
//            "There should be 0 completed sets for the exercise."
//        )
//
//        app.navigationBars.buttons["Home"].tap()
//
//        XCTAssertTrue(
//            app.tables.buttons.firstMatch.staticTexts["1 exercise"].exists,
//            "There should be 2 workouts in the list and the first should have caption text reading '1 exercise'."
//        )
//
//        XCTAssertTrue(
//            app.tables.cells.staticTexts["2 sets"].exists,
//            "There should be 2 workouts in the list and the first should have caption text reading '2 sets'."
//        )
//
//        app.tabBars.buttons["Exercises"].tap()
//        app.tables.cells.buttons["Exercise - 3"].tap()
//
//        XCTAssertTrue(
//            !app.tables.otherElements.staticTexts["Exercise History"].exists,
//            "An exercise history should not yet exist for this exercise since no sets have been completed."
//        )
//
//        app.navigationBars.buttons["Exercises"].tap()
//    }
//
//    func testDeletingAnExercise() throws {
//        try testAddingExerciseToWorkout()
//
//        app.tabBars.buttons["Exercises"].tap()
//        app.tables.cells.buttons["Bench"].tap()
//        app.navigationBars.buttons["Delete"].tap()
//
//        XCTAssertTrue(
//            app.alerts.element.exists,
//            "An alert should be displayed after the user taps to delete an exercise."
//        )
//
//        XCTAssertEqual(
//            app.alerts.element.label,
//            "Are you sure?",
//            "The alert title should read 'Are you sure?'."
//        )
//
//        app.alerts.buttons["Delete"].tap()
//
//        XCTAssertTrue(
//            app.navigationBars["Exercises"].waitForExistence(timeout: 1),
//            "Ensure the user has been popped from the previous navigation link destination."
//        )
//        XCTAssertEqual(
//            app.tables.cells.count,
//            0,
//            "There should be 0 exercises in the list."
//        )
//
//        app.tabBars.buttons["Home"].tap()
//
//        XCTAssertEqual(
//            app.tables.cells.count,
//            1,
//            "There should be 1 workout in the list."
//        )
//
//        XCTAssertTrue(
//            app.tables.cells.staticTexts["No exercises"].exists,
//            "There should be 1 workout in the list with caption text reading 'No exercises'."
//        )
//
//        XCTAssertTrue(
//            app.tables.cells.staticTexts["No sets"].exists,
//            "There should be 1 workout in the scroll view with caption text reading 'No sets'."
//        )
//
//        app.tables.cells.buttons["New Workout"].tap()
//
//        XCTAssertEqual(
//            app.tables.cells.count,
//            5,
//            "There should only be 5 cells in the list."
//        )
//    }
//
//    func testSwipeToDeleteExercise() throws {
//        app.navigationBars.buttons["Sample Data"].tap()
//
//        XCTAssertTrue(
//            app.tables.buttons.firstMatch.staticTexts["1 exercise"].exists,
//            "There should be 2 workouts in the list and the first should have caption text reading '1 exercise'."
//        )
//
//        XCTAssertTrue(
//            app.tables.cells.staticTexts["3 sets"].exists,
//            "There should be 2 workouts in the list and the first should have caption text reading '3 sets'."
//        )
//
//        app.tables.cells.buttons["Workout - 3"].tap()
//
//        XCTAssertTrue(
//            app.tables.cells.count > 5,
//            "There should be at least 5 cells visible since a workout has been added to the exercise."
//        )
//
//        app.tabBars.buttons["Exercises"].tap()
//        app.tables.cells.buttons["Exercise - 3"].swipeLeft()
//        app.tables.cells.buttons["Delete"].tap()
//
//        XCTAssertEqual(
//            app.tables.cells.count,
//            4,
//            "There should be four exercises remaining in the list."
//        )
//
//        XCTAssertTrue(
//            !app.tables.cells.buttons["Exercise - 3"].exists,
//            "There should be no exercise named 'Exercise - 3' in the list."
//        )
//
//        app.tabBars.buttons["Home"].tap()
//
//        XCTAssertEqual(
//            app.tables.cells.count,
//            5,
//            "There should only be 5 cells remaining in the table since the exercise has been deleted."
//        )
//
//        app.navigationBars.buttons["Home"].tap()
//
//        XCTAssertTrue(
//            app.tables.cells.buttons["Workout - 3"].staticTexts["No exercises"].exists,
//            "'Workout - 3' should contain no exercises."
//        )
//
//        XCTAssertTrue(
//            app.tables.cells.buttons["Workout - 3"].staticTexts["No sets"].exists,
//            "'Workout - 3' should contain no sets."
//        )
//    }
//
//    func testEditingTemplateNameIndependentOfWorkout() {
//        app.navigationBars.buttons["Sample Data"].tap()
//        app.scrollViews.buttons.firstMatch.tap()
//        app.tables.cells.buttons["Create workout from template"].tap()
//        app.alerts.buttons["Confirm"].tap()
//        app.navigationBars.buttons["Home"].tap()
//
//        XCTAssertTrue(
//            app.tables.cells.buttons["Workout - 1"].exists,
//            "A workout should have been created from the template."
//        )
//
//        app.scrollViews.buttons.firstMatch.tap()
//        app.textFields["Workout - 1"].tap()
//
//        XCTAssertTrue(
//            app.keys["space"].waitForExistence(timeout: 1),
//            "The keyboard should exist prior to attempting to type."
//        )
//
//        app.keys["space"].tap()
//        app.keys["more"].tap()
//        app.keys["2"].tap()
//        app.buttons["Return"].tap()
//        app.navigationBars.buttons["Home"].tap()
//
//        XCTAssertTrue(
//            app.scrollViews.buttons["Workout - 1 2"].exists,
//            "The template name should have been updated."
//        )
//
//        XCTAssertTrue(
//            app.tables.cells.buttons["Workout - 1"].exists,
//            "The workout name should have remained the same despite the template name changing."
//        )
//
//        XCTAssertTrue(
//            !app.tables.cells.buttons["Workout - 1 2"].exists,
//            "No new workouts should have been created as a result of the template name change."
//        )
//    }
//
//    func testRemovingTemplateExercisesIndependentOfWorkout() {
//        app.navigationBars.buttons["Sample Data"].tap()
//        app.scrollViews.buttons.firstMatch.tap()
//        app.tables.cells.buttons["Create workout from template"].tap()
//        app.alerts.buttons["Confirm"].tap()
//        app.navigationBars.buttons["Home"].tap()
//
//        XCTAssertTrue(
//            app.tables.cells.buttons["Workout - 1"].exists,
//            "A workout should have been created from the template."
//        )
//
//        app.scrollViews.buttons.firstMatch.tap()
//        app.tables.cells.buttons["Remove exercise"].tap()
//        app.alerts.buttons["Remove"].tap()
//        app.navigationBars.buttons["Home"].tap()
//
//        XCTAssertTrue(
//            app.scrollViews.buttons.staticTexts["No exercises"].exists,
//            "The template should contain no exercises."
//        )
//
//        XCTAssertTrue(
//            app.scrollViews.buttons.staticTexts["No sets"].exists,
//            "The template should contain no sets."
//        )
//
//        XCTAssertTrue(
//            app.tables.cells.buttons["Workout - 1"].staticTexts["1 exercise"].exists,
//            "The workout should contain one exercise."
//        )
//
//        XCTAssertTrue(
//            app.tables.cells.buttons["Workout - 1"].staticTexts["3 sets"].exists,
//            "The workout should contain three sets."
//        )
//    }
//
//    func testEditingTemplateExerciseSetIndependentOfWorkout() {
//        app.navigationBars.buttons["Sample Data"].tap()
//        app.scrollViews.buttons.firstMatch.tap()
//        app.tables.cells.buttons["Create workout from template"].tap()
//        app.alerts.buttons["Confirm"].tap()
//        app.navigationBars.buttons["Home"].tap()
//
//        XCTAssertTrue(
//            app.tables.cells.buttons["Workout - 1"].exists,
//            "A workout should have been created from the template."
//        )
//
//        app.scrollViews.buttons.firstMatch.tap()
//
//        XCTAssertTrue(
//            app.tables.cells["1 rep. Mark set incomplete, Decrement, Increment"].waitForExistence(timeout: 1),
//            "The exercise set cell should be visible on screen."
//        )
//
//        XCTAssertEqual(
//            app.tables.cells.matching(identifier: "1 rep. Mark set incomplete, Decrement, Increment").count,
//            1,
//            "There should be exactly one completed workout."
//        )
//
//        app.swipeUp()
//        // swiftlint:disable:next line_length
//        app.tables.cells["1 rep. Mark set incomplete, Decrement, Increment"].children(matching: .other).firstMatch.swipeLeft()
//        app.tables.cells.buttons["Delete"].tap()
//
//        XCTAssertEqual(
//            app.tables.cells.matching(identifier: "1 rep. Mark set incomplete, Decrement, Increment").count,
//            0,
//            "There should be 0 completed sets for the exercise."
//        )
//
//        app.navigationBars.buttons["Home"].tap()
//
//        XCTAssertTrue(
//            app.scrollViews.buttons.staticTexts["2 sets"].exists,
//            "The template should contain no sets."
//        )
//
//        XCTAssertTrue(
//            app.tables.cells.buttons["Workout - 1"].staticTexts["3 sets"].exists,
//            "The workout should contain three sets."
//        )
//    }
//
//    func testCompletingTemplateExerciseSetNoImpactOnExerciseHistory() {
//        app.navigationBars.buttons["Sample Data"].tap()
//
//        app.tabBars.buttons["Exercises"].tap()
//        app.tables.cells.buttons["Exercise - 1"].tap()
//
//        XCTAssertTrue(
//            !app.tables.otherElements.staticTexts["Exercise History"].exists,
//            "An exercise history should not yet exist for this exercise since no sets have been completed."
//        )
//
//        XCTAssertTrue(
//            !app.tables.cells.staticTexts["1 rep"].exists,
//            "No rows should exist in the exercise history."
//        )
//
//        app.navigationBars.buttons["Exercises"].tap()
//    }
//
//    func testSchedulingWorkoutMovesItToHomeTab() {
//        testCompletingWorkoutMovesItToHistoryTab()
//
//        app.tables.cells.buttons["New Workout"].tap()
//        app.tables.cells.buttons["Schedule workout"].tap()
//
//        XCTAssertTrue(
//            app.alerts.element.exists,
//            "An alert should be displayed after the user schedules a workout."
//        )
//
//        XCTAssertEqual(
//            app.alerts.element.label,
//            "Workout Scheduled",
//            "The alert title should read 'Workout Scheduled'."
//        )
//
//        app.alerts.buttons["OK"].tap()
//        app.tabBars.buttons["History"].tap()
//
//        XCTAssertEqual(
//            app.tables.cells.count,
//            0,
//            "There should be 0 workouts on the History tab after the workout has been marked as scheduled."
//        )
//
//        app.tabBars.buttons["Home"].tap()
//
//        XCTAssertEqual(
//            app.tables.cells.count,
//            1,
//            "There should be 1 workout on the Home tab after the workout has been marked as scheduled."
//        )
//    }
// swiftlint:disable:next file_length
}
