//
//  OlioExercise.swift
//  Olio
//
//  Created by Jake King on 10/01/2022.
//

import Foundation

struct OlioExercise: Decodable, Identifiable {
    var id: String { name }
    let name: String
    let category: Int16
    let muscleGroup: Int16

    static let allOlioExercises = Bundle.main.decode([OlioExercise].self,
                                                      from: "Exercises.json")
    static let example = allOlioExercises[0]
}
