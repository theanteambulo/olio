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
