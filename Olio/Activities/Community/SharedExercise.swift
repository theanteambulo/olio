//
//  SharedExercise.swift
//  Olio
//
//  Created by Jake King on 22/03/2022.
//

import Foundation

struct SharedExercise: Identifiable {
    let id: String
    let name: String
    let category: String
    let muscleGroup: String
    let placement: Int
    let setCount: Int
    let targetReps: Int
    let targetWeight: Double

    static let example = SharedExercise(
        id: "1",
        name: "1",
        category: "1",
        muscleGroup: "1",
        placement: 0,
        setCount: 0,
        targetReps: 0,
        targetWeight: 0
    )
}
