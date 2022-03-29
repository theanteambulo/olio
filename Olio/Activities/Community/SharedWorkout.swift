//
//  SharedWorkout.swift
//  Olio
//
//  Created by Jake King on 22/03/2022.
//

import Foundation

struct SharedWorkout: Identifiable {
    let id: String
    let name: String
    let owner: String
    
    static let example = SharedWorkout(id: "1", name: "Example Workout", owner: "theAnteambulo")
}
