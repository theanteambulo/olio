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
            Text(workout.workoutName)
        }
    }
}

struct WorkoutRowView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutRowView(workout: Workout.example)
    }
}
