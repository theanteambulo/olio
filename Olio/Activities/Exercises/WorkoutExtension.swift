//
//  WorkoutExtension.swift
//  Olio
//
//  Created by Jake King on 23/11/2021.
//

import Foundation

extension Workout {
    var workoutName: String {
        name ?? ""
    }

    var workoutDateScheduled: Date {
        dateScheduled ?? Date()
    }

    var formattedWorkoutDateScheduled: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: workoutDateScheduled)
    }

    var workoutDateCompleted: Date {
        dateCompleted ?? Date()
    }

    var formattedWorkoutDateCompleted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: workoutDateScheduled)
    }

    var workoutExercises: [Exercise] {
        let exercisesArray = exercises?.allObjects as? [Exercise] ?? []
        return exercisesArray
    }

    static var example: Workout {
        let dataController = DataController(inMemory: true)
        let viewContext = dataController.container.viewContext

        let workout = Workout(context: viewContext)
        workout.name = "Example Workout"
        workout.template = Bool.random()
        workout.dateScheduled = Date()
        workout.dateCompleted = Date()
        workout.completed = true

        return workout
    }
}
