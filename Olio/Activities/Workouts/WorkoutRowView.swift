//
//  WorkoutRowView.swift
//  Olio
//
//  Created by Jake King on 25/11/2021.
//

import SwiftUI

struct WorkoutRowView: View {
    @ObservedObject var workout: Workout

    var body: some View {
        NavigationLink(destination: EditWorkoutView(workout: workout)) {
            HStack {
                Image(systemName: "tortoise.fill")
                    .foregroundColor(workout.completed ? .clear : .primary)
                Text(workout.workoutName)
            }
        }
    }
}

struct WorkoutRowView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutRowView(workout: Workout.example)
    }
}
