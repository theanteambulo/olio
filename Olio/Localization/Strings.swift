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
    case exerciseSettings
    case completeButton
    case incompleteButton
    case oops
    case enableNotifications
    case enableNotificationsError
    case settings
    case error
    case noResults
    case sendButton
    case oopsError
    case allSet
    case signIn
    case takeAction
    case noThanks
    case noCompleteWorkoutsYet

    // ONBOARDING
    case olio
    case olioSubtitle
    case exercisesDownloadedSubtitle
    case downloadExercisesSubtitle
    case exercisesDownloaded
    case templatesSubtitle
    case notifications
    case notificationsSubtitle
    case enableNotificationsButton
    case notificationsEnabled
    case historySubtitle
    case communitySubtitle

    // TABS
    case homeTab
    case historyTab
    case exercisesTab
    case communityTab

    // WORKOUTS
    case workoutTemplates
    case workoutsScheduled
    case selectOption
    case newTemplate
    case newWorkout
    case addNewTemplate
    case addNewWorkout
    case noExercises
    case creator
    case uploadWorkout
    case uploadWorkoutMessage
    case removeWorkout
    case removeWorkoutMessage
    case downloadWorkout
    case downloadWorkoutMessage
    case downloadComplete

    // EDITING WORKOUTS
    case editWorkoutNavigationTitle
    case editTemplateNavigationTitle
    case workoutName
    case templateName
    case completedSectionHeader
    case scheduledSectionHeader
    case workoutDate
    case today
    case tomorrow
    case selectWorkoutDateLabel
    case selectWorkoutDateMessage
    case workoutReminderTimeSectionHeader
    case showReminders
    case reminderTime
    case addExercisesToWorkout
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
    case removeExerciseButton
    case removeExerciseConfirmationMessage
    case completeNextSetButton

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
    case weightsAndBody
    case cardio
    case exerciseClass
    case stretch
    case errorAlertTitle
    case duplicationErrorAlertMessage
    case emptyNameErrorAlertMessage
    case noExercisesYetTitle
    case noExercisesYetMessage
    case noExercisesYetTabMessage
    case loadOlioExercises
    case targetWeight
    case notApplicable
    case unknownExercise
    case unknownCategory
    case unknownMuscleGroup

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
    case workoutHasIncompleteSetsAlertMessage
    case workoutScheduledAlertTitle
    case workoutScheduledAlertMessage

    // SETS
    case addSet
    case markSetComplete
    case markSetIncomplete
    case repLimitError
    case weightLimitError
    case repAndWeightLimitError
    case distanceLimitError
    case secsDurationLimitError
    case minsDurationLimitError
    case distanceAndDurationLimitError

    // COMMUNITY
    case sharedWorkouts
    case signInToComment
    case enterYourMessage
    case discussion
    case communitySafetyMessage

    // ERROR HANDLING
    case communicatingWithCloud
    case cloudAccount
    case rateLimit
    case quotaExceeded

    var localized: LocalizedStringKey {
        self.rawValue
    }
}
