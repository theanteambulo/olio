//
//  TemplateCardView.swift
//  Olio
//
//  Created by Jake King on 01/12/2021.
//

import SwiftUI

/// A single card representing a given workout template.
struct TemplateCardView: View {
    /// The workout template used to construct this view.
    @ObservedObject var template: Workout

    /// The array of colors corresponding to unique exercise categories in this workout.
    private var exerciseCategoryColors: [Color]

    /// A grid with a single row.
    var rows: [GridItem] {
        Array(repeating: GridItem(.fixed(7)), count: 1)
    }

    init(template: Workout) {
        self.template = template
        exerciseCategoryColors = [Color]()

        for exercise in template.workoutExercises.sorted(by: \.exerciseCategory) {
            exerciseCategoryColors.append(exercise.getExerciseCategoryColor())
        }

        exerciseCategoryColors.removeDuplicates()
    }

    var body: some View {
        NavigationLink(destination: EditWorkoutView(workout: template)) {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(template.workoutName)")
                    .foregroundColor(.primary)
                    .font(.headline)
                    .frame(minWidth: 125,
                           alignment: .leading)

                if !template.workoutExercises.isEmpty {
                    LazyHGrid(rows: rows, spacing: 7) {
                        ForEach(exerciseCategoryColors, id: \.self) { categoryColor in
                            Circle()
                                .frame(width: 7)
                                .foregroundColor(categoryColor)
                        }
                    }
                }

                Group {
                    Text("\(template.workoutExercises.count) exercises")

                    Text("\(template.workoutExerciseSets.count) sets")
                }
                .font(.caption)
                .foregroundColor(.white)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityIdentifier(template.workoutName)
        }
        .padding(10)
        .frame(maxHeight: .infinity)
        .background(Color.secondarySystemGroupedBackground)
        .cornerRadius(5)
        .shadow(color: Color.black.opacity(0.2),
                radius: 5)
    }
}

struct TemplateCardView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateCardView(template: Workout.example)
    }
}
