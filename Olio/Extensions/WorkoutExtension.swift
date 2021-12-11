//
//  WorkoutExtension.swift
//  Olio
//
//  Created by Jake King on 23/11/2021.
//

import Foundation
import SwiftUI

extension Workout {
    /// The unwrapped id property of a workout.
    var workoutId: String {
        id?.uuidString ?? ""
    }

    /// The unwrapped name property of a workout.
    var workoutName: String {
        template
        ? name ?? NSLocalizedString("newTemplate",
                                    comment: "Create a new template")
        : name ?? NSLocalizedString("newWorkout",
                                    comment: "Create a new workout")
    }

    /// The unwrapped date property of a workout.
    var workoutDate: Date {
        date ?? Date()
    }

    /// The unwrapped date property of a workout formatter as a string.
    var formattedWorkoutDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: workoutDate)
    }

    /// The unwrapped exercises a workout is parent of.
    var workoutExercises: [Exercise] {
        exercises?.allObjects as? [Exercise] ?? []
    }

    /// The unwrapped exercise sets a workout is parent of.
    var workoutExerciseSets: [ExerciseSet] {
        sets?.allObjects as? [ExerciseSet] ?? []
    }

    /// An example workout for previewing purposes.
    static var example: Workout {
        let dataController = DataController.preview
        let viewContext = dataController.container.viewContext

        let workout = Workout(context: viewContext)
        workout.name = "Example Workout"
        workout.date = Date()
        workout.completed = true

        return workout
    }

    /// Derives the title of an alert displayed when a user completes or schedules a workout.
    ///
    /// Conditional on whether the workout is already complete or not.
    /// - Parameter workout: The workout being completed or scheduled.
    /// - Returns: A LocalizedStringKey corresponding to the action taken on the workout (i.e. complete or schedule).
    func getConfirmationAlertTitle(workout: Workout) -> LocalizedStringKey {
        return workout.completed
        ? Strings.workoutScheduledAlertTitle.localized
        : Strings.workoutCompletedAlertTitle.localized
    }

    /// Derives the message of an alert displayed when a user completes or schedules a workout.
    /// - Parameter workout: The workout being completed or scheduled.
    /// - Returns: A LocalizedStringKey corresponding to the action taken on the workout (i.e. complete or schedule).
    func getConfirmationAlertMessage(workout: Workout) -> LocalizedStringKey {
        if workout.completed {
            return Strings.workoutScheduledAlertMessage.localized
        } else {
            return Strings.workoutCompletedAlertMessage.localized
        }
    }
}
