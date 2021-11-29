//
//  WorkoutExtension.swift
//  Olio
//
//  Created by Jake King on 23/11/2021.
//

import Foundation

extension Workout {
    var workoutId: String {
        id?.uuidString ?? ""
    }

    var workoutName: String {
        name ?? ""
    }

    var workoutDateScheduled: Date {
        dateScheduled ?? Date()
    }

    var formattedWorkoutDateScheduled: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: workoutDateScheduled)
    }

    var workoutDateCompleted: Date {
        dateCompleted ?? Date()
    }

    var formattedWorkoutDateCompleted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: workoutDateCompleted)
    }

    var workoutExercises: [Exercise] {
        exercises?.allObjects as? [Exercise] ?? []
    }

    var workoutExerciseSets: [ExerciseSet] {
        sets?.allObjects as? [ExerciseSet] ?? []
    }

    static var example: Workout {
        let dataController = DataController(inMemory: true)
        let viewContext = dataController.container.viewContext

        let workout = Workout(context: viewContext)
        workout.name = "Example Workout"
        workout.dateScheduled = Date()
        workout.dateCompleted = Date()
        workout.completed = true

        return workout
    }

    func getConfirmationAlertTitle(workout: Workout) -> String {
        return workout.completed ? "Workout Scheduled" : "Workout Complete"
    }

    func getConfirmationAlertMessage(workout: Workout) -> String {
        if workout.completed {
            return "This workout will now move to your scheduled workouts. Get after it!"
        } else {
            return "Smashed it! This workout will now move to your workout history."
        }
    }
}
