//
//  ExerciseExtension.swift
//  Olio
//
//  Created by Jake King on 23/11/2021.
//

import Foundation

extension Exercise {
    var exerciseId: String {
        id?.uuidString ?? ""
    }

    var exerciseName: String {
        name ?? NSLocalizedString("newExercise",
                                  comment: "Create a new exercise")
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

    enum MuscleGroup: String, CaseIterable {
        case chest = "Chest"
        case back = "Back"
        case shoulders = "Shoulders"
        case biceps = "Biceps"
        case triceps = "Triceps"
        case legs = "Legs"
        case abs = "Abs"
    }

    var exerciseSets: [ExerciseSet] {
        sets?.allObjects as? [ExerciseSet] ?? []
    }

    var exerciseWorkouts: [Workout] {
        workouts?.allObjects as? [Workout] ?? []
    }

    static var example: Exercise {
        let dataController = DataController.preview
        let viewContext = dataController.container.viewContext

        let exercise = Exercise(context: viewContext)
        exercise.name = "Example Exercise"
        exercise.bodyweight = true
        exercise.muscleGroup = Int16.random(in: 1...7)
        exercise.sets = [ExerciseSet.example]

        return exercise
    }
}
