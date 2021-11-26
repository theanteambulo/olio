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

    var exerciseSets: [ExerciseSet] {
        sets?.allObjects as? [ExerciseSet] ?? []
    }

    static var example: Exercise {
        let dataController = DataController(inMemory: true)
        let viewContext = dataController.container.viewContext

        let exercise = Exercise(context: viewContext)
        exercise.name = "Example Exercise"
        exercise.bodyweight = Bool.random()
        exercise.muscleGroup = Int16.random(in: 1...7)
        exercise.sets = [ExerciseSet.example]

        return exercise
    }
}
