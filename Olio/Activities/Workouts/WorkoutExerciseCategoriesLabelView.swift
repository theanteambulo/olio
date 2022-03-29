//
//  WorkoutExerciseCategoriesLabelView.swift
//  Olio
//
//  Created by Jake King on 29/03/2022.
//

import SwiftUI

struct WorkoutExerciseCategoriesLabelView: View {
    @ObservedObject var workout: Workout

    var body: some View {
        // Map all the exercises into an array of categories (strings)
        let categories = workout.workoutExercises.map({ $0.exerciseCategory })
        let colors = Exercise.allExerciseCategoryColors

        switch categories.count {
        case 2:
            let freeWeights = Text(.weights).font(.caption).foregroundColor(colors["Free Weights"])
            let divider = Text(" | ").font(.caption).foregroundColor(.secondary)
            let bodyWeight = Text(.body).font(.caption).foregroundColor(colors["Bodyweight"])

            return freeWeights + divider + bodyWeight
        case 1:
            let divider = Text(" | ").font(.caption).foregroundColor(.secondary)

            if categories.contains("Free Weights") {
                let freeWeights = Text(.weights).font(.caption).foregroundColor(colors["Free Weights"])
                let bodyWeight = Text(.body).font(.caption).foregroundColor(.secondary)

                return freeWeights + divider + bodyWeight
            } else {
                let freeWeights = Text(.weights).font(.caption).foregroundColor(.secondary)
                let bodyWeight = Text(.body).font(.caption).foregroundColor(colors["Body"])

                return freeWeights + divider + bodyWeight
            }
        default:
            return Text(.weightsAndBody).font(.caption).foregroundColor(.secondary)
        }
    }
}

struct WorkoutExerciseCategoriesLabelView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutExerciseCategoriesLabelView(workout: Workout.example)
    }
}
