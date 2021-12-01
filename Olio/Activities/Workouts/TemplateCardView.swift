//
//  TemplateCardView.swift
//  Olio
//
//  Created by Jake King on 01/12/2021.
//

import SwiftUI

struct TemplateCardView: View {
    @ObservedObject var template: Workout

    var body: some View {
        NavigationLink(destination: EditWorkoutView(workout: template)) {
            VStack(alignment: .leading) {
                Text("\(template.workoutName)")
                    .foregroundColor(.primary)
                    .frame(minWidth: 125,
                           alignment: .leading)

                Text("\(template.workoutExercises.count) exercises, \(template.workoutExerciseSets.count) sets")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color.secondarySystemGroupedBackground)
        .cornerRadius(5)
        .shadow(color: Color.black.opacity(0.2),
                radius: 5)
        .accessibilityElement(children: .ignore)
    }
}

struct TemplateCardView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateCardView(template: Workout.example)
    }
}
