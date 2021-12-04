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

    func testHomeTabAddsWorkout() throws {
        XCTAssertEqual(
            app.tables.cells.count,
            0,
            "There should be no workouts initially."
        )

        for workoutCount in 1...5 {
            app.buttons["Add"].tap()
            app.buttons["New Workout"].tap()

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
            app.buttons["New Template"].tap()

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
        app.buttons["New Template"].tap()

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
        app.buttons["New Workout"].tap()

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
}
