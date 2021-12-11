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

    var body: some View {
        NavigationLink(destination: EditWorkoutView(workout: template)) {
            VStack(alignment: .leading) {
                Text("\(template.workoutName)")
                    .foregroundColor(.primary)
                    .frame(minWidth: 125,
                           alignment: .leading)

                Text("\(template.workoutExercises.count) exercises")
                    .foregroundColor(.secondary)
                    .font(.caption)

                Text("\(template.workoutExerciseSets.count) sets")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color.secondarySystemGroupedBackground)
        .cornerRadius(5)
        .shadow(color: Color.black.opacity(0.2),
                radius: 5)
        .accessibilityIdentifier(template.workoutName)
    }
}

struct TemplateCardView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateCardView(template: Workout.example)
    }
}
