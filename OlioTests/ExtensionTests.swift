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
    /// Tests that an array of Comparable objects is sorted correctly.
    func testSequenceKeyPathSortingSelf() {
        let items = [2, 3, 5, 1, 4]
        let sortedItems = items.sorted(by: \.self)

        XCTAssertEqual(
            sortedItems,
            [1, 2, 3, 4, 5],
            "The array should contain the integers 1-5 in ascending order."
        )
    }

    /// Tests that an array of non-Comparable objects can be sorted by a specified key path.
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

    /// Tests that a given handler function will be called when the value of a binding is changed.
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

    /// Tests that the extension on Bundle is able to decode an array of Exercise objects from Exercises.json.
    func testBundleExtensionDecodesExercisesJson() {
        let olioExercises = Bundle.main.decode([OlioExercise].self, from: "Exercises.json")

        XCTAssertFalse(
            olioExercises.isEmpty,
            "The Exercises.json should decode to a non-empty array."
        )
    }

    /// Tests that the extension on Bundle is able to decode dictionaries of data.
    func testBundleExtensionDecodesDictionaries() {
        let bundle = Bundle(for: ExtensionTests.self)
        let dictionary = bundle.decode([String: Int].self, from: "DecodableDictionary.json")

        XCTAssertEqual(
            dictionary.count,
            3,
            "There should be 3 items decoded from DecodableDictionary.json."
        )

        XCTAssertEqual(
            dictionary["One"],
            1,
            "The dictionary should contain string to integer mappings."
        )
    }

    /// Tests that the extension on Bundle is able to decode strings of data.
    func testBundleExtensionDecodesStrings() {
        let bundle = Bundle(for: ExtensionTests.self)
        let string = bundle.decode(String.self, from: "DecodableString.json")

        XCTAssertEqual(
            string,
            "The Olio app will make you big, strong, handsome, smart, funny and modest.",
            "The string must match the content of DecodableString.json."
        )
    }
}
