//
//  ExerciseExtension.swift
//  Olio
//
//  Created by Jake King on 23/11/2021.
//

import Foundation

extension Exercise {
    var exerciseName: String {
        name ?? ""
    }

    var exerciseMuscleGroup: String {
        switch muscleGroup {
        case Int16(1):
            return "Chest"
        case Int16(2):
            return "Back"
        case Int16(3):
            return "Shoulders"
        case Int16(4):
            return "Biceps"
        case Int16(5):
            return "Triceps"
        case Int16(6):
            return "Legs"
        default:
            return "Abs"
        }
    }

    static var example: Exercise {
        let dataController = DataController(inMemory: true)
        let viewContext = dataController.container.viewContext

        let exercise = Exercise(context: viewContext)
        exercise.name = "Example Exercise"
        exercise.bodyweight = Bool.random()
        exercise.muscleGroup = Int16.random(in: 1...7)
        exercise.reps = 10
        exercise.sets = 3

        return exercise
    }
}
