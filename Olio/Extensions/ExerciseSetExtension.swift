//
//  ExerciseSetExtension.swift
//  Olio
//
//  Created by Jake King on 24/11/2021.
//

import Foundation

extension ExerciseSet {
    var exerciseSetReps: Int {
        Int(reps)
    }

    static var example: ExerciseSet {
        let dataController = DataController(inMemory: true)
        let viewContext = dataController.container.viewContext

        let exerciseSet = ExerciseSet(context: viewContext)
        exerciseSet.reps = 10
        exerciseSet.weight = 0

        return exerciseSet
    }
}
