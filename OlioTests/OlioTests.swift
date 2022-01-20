//
//  OlioTests.swift
//  OlioTests
//
//  Created by Jake King on 03/12/2021.
//

import CoreData
import XCTest

// Import all of the main Olio target for testing. This allows us to access all parts of the project directly, without
// needing to declare them as public.
@testable import Olio

class BaseTestCase: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!

    // Create a DataController instance before every test runs so all subsequent tests have access to storage as needed.
    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}

// testCreatingSampleData
// testDeleteAllRemovesAllDataFromStorage
// testExampleWorkoutIsCompleted
// testExampleExerciseIsBodyWeight???
// testExamplePlacementIsIndexZero???
// testExampleExerciseSetIsIncomplete

// testSequenceKeyPathSortingSelf
// testSequenceKeyPathSortingCustom
// testBindingCallsFunctionOnChange

// testNewUserHasNoWorkoutsExercisesOrExerciseSets???
// testCreatingWorkoutsExercisesAndSets
// testDeletingWorkoutCascadeDeletesSetsAndPlacementsNotExercises???
// testDeletingExercisesCascadeDeletesSetsAndPlacementsNotExercises???
// testDeletingExerciseSetsNoCascadeDeleteExerciseOrWorkouts???
