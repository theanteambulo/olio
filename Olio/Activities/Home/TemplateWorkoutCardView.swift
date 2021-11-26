//
//  TemplateWorkoutCardView.swift
//  Olio
//
//  Created by Jake King on 25/11/2021.
//

import SwiftUI

struct TemplateWorkoutCardView: View {
    @ObservedObject var workout: Workout

    var body: some View {
        // View to ensure that a template card is clickable, editable and instantly updates in HomeView.
        NavigationLink(destination: EditWorkoutView(workout: workout)) {
            VStack(alignment: .leading) {
                Text("\(workout.workoutExercises.count) exercises")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(workout.workoutName)
                    .font(.title3)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color.secondarySystemGroupedBackground)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 5)
    }
}

struct TemplateWorkoutCardView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateWorkoutCardView(workout: Workout.example)
    }
}
