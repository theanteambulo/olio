//
//  WorkoutExerciseCategoriesLabelView.swift
//  Olio
//
//  Created by Jake King on 29/03/2022.
//

import SwiftUI

struct WorkoutExerciseCategoriesLabelView: View {
    @ObservedObject var workout: Workout

    private var categories: [String]
    private let colors = Exercise.allExerciseCategoryColors

    init(workout: Workout) {
        self.workout = workout
        self.categories = workout.workoutExercises.sorted(by: \.exerciseCategory).map({
            $0.exerciseCategory
        }).removingDuplicates()
    }

    var bothCategories: some View {
        let freeWeights = Text(.weights).font(.caption).foregroundColor(colors["Free Weights"])
        let divider = Text(" | ").font(.caption).foregroundColor(.secondary)
        let bodyWeight = Text(.body).font(.caption).foregroundColor(colors["Bodyweight"])

        let text = freeWeights + divider + bodyWeight

        return text
    }

    var oneCategory: Text {
        let divider = Text(" | ").font(.caption).foregroundColor(.secondary)

        if categories.contains("Free Weights") {
            let freeWeights = Text(.weights).font(.caption).foregroundColor(colors["Free Weights"])
            let bodyWeight = Text(.body).font(.caption).foregroundColor(.secondary)

            let text = freeWeights + divider + bodyWeight

            return text
        } else {
            let freeWeights = Text(.weights).font(.caption).foregroundColor(.secondary)
            let bodyWeight = Text(.body).font(.caption).foregroundColor(colors["Bodyweight"])

            let text = freeWeights + divider + bodyWeight

            return text
        }
    }

    var noCategories: Text {
        Text(.weightsAndBody)
            .font(.caption)
            .foregroundColor(.secondary)
    }

    var body: some View {
        switch categories.count {
        case 2:
            bothCategories
        case 1:
            oneCategory
        default:
            noCategories
        }
    }
}

struct WorkoutExerciseCategoriesLabelView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutExerciseCategoriesLabelView(workout: Workout.example)
    }
}
