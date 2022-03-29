//
//  ExerciseExtension.swift
//  Olio
//
//  Created by Jake King on 23/11/2021.
//

import Foundation
import SwiftUI

extension Exercise {
    /// The unwrapped id property of an exercise.
    var exerciseId: String {
        id?.uuidString ?? ""
    }

    /// The unwrapped name property of an exercise.
    var exerciseName: String {
        name ?? NSLocalizedString("newExercise",
                                  comment: "Create a new exercise")
    }

    /// The unwrapped category property of an exercise as a String.
    var exerciseCategory: String {
        switch category {
        case Int16(1):
            return "Free Weights"
        case Int16(2):
            return "Bodyweight"
        case Int16(3):
            return "Cardio"
        case Int16(4):
            return "Class"
        default:
            return "Stretch"
        }
    }

    static let allExerciseCategoryColors: [String: Color] = [
        "Free Weights": .red,
        "Bodyweight": .blue
    ]

    func getExerciseCategoryColor() -> Color {
        switch exerciseCategory {
        case "Free Weights":
            return Exercise.allExerciseCategoryColors["Free Weights"] ?? .clear
        case "Bodyweight":
            return Exercise.allExerciseCategoryColors["Bodyweight"] ?? .clear
//        case "Cardio":
//            return .green
//        case "Class":
//            return .yellow
//        default:
//            return .purple
        default:
            return .clear
        }
    }

    /// An enum containing all possible cases for an exercise category.
    enum ExerciseCategory: String, CaseIterable {
        case weighted = "Weights"
        case bodyweight = "Body"
//        case cardio = "Cardio"
//        case exerciseClass = "Class"
//        case stretch = "Stretch"
    }

    /// The unwrapped muscle group property of an exercise.
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
        case Int16(7):
            return "Abs"
        default:
            return "Full Body"
        }
    }

    /// An enum containing all possible cases for an exercise muscle group.
    enum MuscleGroup: String, CaseIterable {
        case chest = "Chest"
        case back = "Back"
        case shoulders = "Shoulders"
        case biceps = "Biceps"
        case triceps = "Triceps"
        case legs = "Legs"
        case abs = "Abs"
        case fullBody = "Full Body"
    }

    /// The unwrapped exercise sets an exercise is parent of.
    var exerciseSets: [ExerciseSet] {
        sets?.allObjects as? [ExerciseSet] ?? []
    }

    /// The unwrapped workouts an exercise belongs to.
    var exerciseWorkouts: [Workout] {
        workouts?.allObjects as? [Workout] ?? []
    }

    /// The unwrapped placements a exercise is parent of.
    var exercisePlacements: [Placement] {
        placements?.allObjects as? [Placement] ?? []
    }

    /// An example exercise for previewing purposes.
    static var example: Exercise {
        let dataController = DataController.preview
        let viewContext = dataController.container.viewContext

        let exercise = Exercise(context: viewContext)
        exercise.name = "Example Exercise"
        exercise.category = 0
        exercise.muscleGroup = Int16.random(in: 1...7)
        exercise.sets = [ExerciseSet.example]

        return exercise
    }
}
