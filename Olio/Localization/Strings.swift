//
//  Strings.swift
//  Olio
//
//  Created by Jake King on 02/12/2021.
//

import SwiftUI

extension Text {
    init(_ localizedString: Strings) {
        self.init(localizedString.rawValue)
    }
}

enum Strings: LocalizedStringKey {
    // GENERAL
    case okButton
    case areYouSureAlertTitle
    case confirmButton
    case deleteButton
    case removeButton
    case cancelButton
    case addExercise
    case basicSettings
    case completeButton
    case incompleteButton

    // TABS
    case homeTab
    case historyTab
    case exercisesTab

    // WORKOUTS
    case workoutTemplates
    case workoutsScheduled
    case selectOption
    case newTemplate
    case newWorkout

    // EDITING WORKOUTS
    case editWorkoutNavigationTitle
    case editTemplateNavigationTitle
    case workoutName
    case completedSectionHeader
    case scheduledSectionHeader
    case workoutDate
    case today
    case tomorrow
    case selectWorkoutDateLabel
    case selectWorkoutDateMessage
    case scheduleWorkout
    case completeWorkout
    case markWorkoutIncomplete
    case createTemplateFromWorkoutButton
    case createTemplateConfirmationTitle
    case createTemplateConfirmationMessage
    case createWorkoutFromTemplateButton
    case createWorkoutConfirmationTitle
    case createWorkoutConfirmationMessage
    case deleteWorkoutButton
    case deleteWorkoutConfirmationMessage
    case deleteTemplateButton
    case deleteTemplateConfirmationMessage
    case addSet
    case removeExerciseButton
    case removeExerciseConfirmationMessage
    case markSetComplete
    case markSetIncomplete

    // EXERCISES
    case exerciseNavigationTitle
    case deleteExerciseConfirmationMessage
    case saveButton
    case exerciseName
    case exerciseCategory
    case muscleGroup
    case chest
    case back
    case shoulders
    case biceps
    case triceps
    case legs
    case abs
    case fullBody
    case weights
    case body
    case cardio
    case exerciseClass
    case stretch
    case errorAlertTitle
    case duplicationErrorAlertMessage
    case emptyNameErrorAlertMessage

    // EDIT EXERCISE
    case editExerciseNavigationTitle
    case exerciseHistory
    case workoutDateMissing
    case workoutNameMissing
    case saveChanges

    // WORKOUT EXTENSION
    case exampleWorkout
    case workoutCompletedAlertTitle
    case workoutCompletedAlertMessage
    case workoutScheduledAlertTitle
    case workoutScheduledAlertMessage

    // EXERCISE EXTENSION
    case exampleExercise

    var localized: LocalizedStringKey {
        self.rawValue
    }
}
