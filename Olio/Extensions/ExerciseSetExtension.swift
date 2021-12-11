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
