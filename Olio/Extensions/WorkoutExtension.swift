//
//  WorkoutExtension.swift
//  Olio
//
//  Created by Jake King on 23/11/2021.
//

import Foundation
import SwiftUI

extension Workout {
    var workoutId: String {
        id?.uuidString ?? ""
    }

    var workoutName: String {
        template
        ? name ?? NSLocalizedString("newTemplate",
                                    comment: "Create a new template")
        : name ?? NSLocalizedString("newWorkout",
                                    comment: "Create a new workout")
    }

    var workoutDate: Date {
        date ?? Date()
    }

    var formattedWorkoutDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: workoutDate)
    }

    var workoutExercises: [Exercise] {
        exercises?.allObjects as? [Exercise] ?? []
    }

    var workoutExerciseSets: [ExerciseSet] {
        sets?.allObjects as? [ExerciseSet] ?? []
    }

    static var example: Workout {
        let dataController = DataController.preview
        let viewContext = dataController.container.viewContext

        let workout = Workout(context: viewContext)
        workout.name = "Example Workout"
        workout.date = Date()
        workout.completed = true

        return workout
    }

    func getConfirmationAlertTitle(workout: Workout) -> LocalizedStringKey {
        return workout.completed
        ? Strings.workoutScheduledAlertTitle.localized
        : Strings.workoutCompletedAlertTitle.localized
    }

    func getConfirmationAlertMessage(workout: Workout) -> LocalizedStringKey {
        if workout.completed {
            return Strings.workoutScheduledAlertMessage.localized
        } else {
            return Strings.workoutCompletedAlertMessage.localized
        }
    }
}
