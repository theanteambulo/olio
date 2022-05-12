//
//  PlacementExtension.swift
//  Olio
//
//  Created by Jake King on 15/01/2022.
//

import Foundation

extension Placement {
    /// The unwrapped id property of a placement.
    var placementId: String {
        id?.uuidString ?? ""
    }

    /// The unwrapped index property of a placement.
    var placementIndexPosition: Int {
        Int(indexPosition)
    }

    /// An example exercise for previewing purposes.
    static var example: Placement {
        let dataController = DataController.preview
        let viewContext = dataController.container.viewContext

        let placement = Placement(context: viewContext)
        placement.indexPosition = 0
        placement.workout = Workout.example
        placement.exercise = Exercise.example

        return placement
    }
}
