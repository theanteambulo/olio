//
//  ExtensionTests.swift
//  OlioTests
//
//  Created by Jake King on 04/12/2021.
//

import SwiftUI
import XCTest
@testable import Olio

class ExtensionTests: XCTestCase {
    func testSequenceKeyPathSortingSelf() {
        let items = [2, 3, 5, 1, 4]
        let sortedItems = items.sorted(by: \.self)

        XCTAssertEqual(
            sortedItems,
            [1, 2, 3, 4, 5],
            "The array should contain the integers 1-5 in ascending order."
        )
    }

    func testSequenceKeyPathSortingCustom() {
        struct User: Equatable {
            let name: String
        }

        let userA = User(name: "Jake")
        let userB = User(name: "Cal")
        let userC = User(name: "Dan")
        let userD = User(name: "Tom")

        let userArray = [userA, userB, userC, userD]

        XCTAssertEqual(
            userArray.sorted(by: \.name, using: >),
            [userD, userA, userC, userB],
            "The array should contain the users reverse sorted alphabetically by name."
        )
    }

    func testBindingCallsFunctionOnChange() {
        var onChangeFunctionRun = false

        func exampleFunctionToCallOnChange() {
            onChangeFunctionRun = true
        }

        var storedValue = ""

        let bindingToChange = Binding(
            get: { storedValue },
            set: { storedValue = $0 }
        )

        let changedBinding = bindingToChange.onChange(exampleFunctionToCallOnChange)

        changedBinding.wrappedValue = "Test"

        XCTAssert(
            onChangeFunctionRun,
            "The exampleFunctionToCallOnChange() function was not run."
        )
    }
}
