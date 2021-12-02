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

    // TABS
    case homeTab
    case historyTab
    case exercisesTab

    // WORKOUTS
    case workoutTemplates
    case workoutsScheduled
    case nothingToSeeHere
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
    case workoutDateChanged
    case completedWorkoutDateChangeAlertMessage
    case scheduledWorkoutDateChangeAlertMessage
    case scheduleWorkout
    case completeWorkout
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

    // EXERCISES
    case exerciseNavigationTitle
    case saveButton
    case exerciseName
    case muscleGroup
    case chest
    case back
    case shoulders
    case biceps
    case triceps
    case legs
    case abs
    case duplicationErrorAlertTitle
    case duplicationErrorAlertMessage

    // EDIT EXERCISE
    case editExerciseNavigationTitle
    case exerciseHistory
    case workoutDateMissing
    case workoutNameMissing

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
