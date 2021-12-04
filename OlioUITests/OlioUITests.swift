//
//  OlioUITests.swift
//  OlioUITests
//
//  Created by Jake King on 04/12/2021.
//

import XCTest

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

    // HOME
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

    func testChangingWorkoutDate() {
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

//    func testCreatingWorkoutFromTemplate() {
//    }
//
//    func testDeletingWorkout() {
//    }
}
