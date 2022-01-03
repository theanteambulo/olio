//
//  ExerciseSetExtension.swift
//  Olio
//
//  Created by Jake King on 24/11/2021.
//

import Foundation

extension ExerciseSet {
    /// The unwrapped id property of an exercise set.
    var exerciseSetId: String {
        id?.uuidString ?? ""
    }

    /// The unwrapped reps property of an exercise set.
    var exerciseSetReps: Int {
        Int(reps)
    }

    /// The unwrapped weight property of an exercise set.
    var exerciseSetWeight: Double {
        Double(weight)
    }

    /// The unwrapped distance property of an exercise set.
    var exerciseSetDistance: Double {
        Double(distance)
    }

    /// The unwrapped duration property of an exercise set.
    var exerciseSetDuration: Int {
        Int(duration)
    }

    /// The unwrapped creation date property of an exercise set.
    var exerciseSetCreationDate: Date {
        creationDate ?? Date()
    }

    /// An example exercise set for previewing purposes.
    static var example: ExerciseSet {
        let dataController = DataController.preview
        let viewContext = dataController.container.viewContext

        let exerciseSet = ExerciseSet(context: viewContext)
        exerciseSet.reps = 10
        exerciseSet.weight = 0
        exerciseSet.completed = false

        return exerciseSet
    }
}
