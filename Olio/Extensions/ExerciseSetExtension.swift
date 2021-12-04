//
//  ExerciseSetExtension.swift
//  Olio
//
//  Created by Jake King on 24/11/2021.
//

import Foundation

extension ExerciseSet {
    var exerciseSetId: String {
        id?.uuidString ?? ""
    }

    var exerciseSetReps: Int {
        Int(reps)
    }

    var exerciseSetCreationDate: Date {
        creationDate ?? Date()
    }

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
