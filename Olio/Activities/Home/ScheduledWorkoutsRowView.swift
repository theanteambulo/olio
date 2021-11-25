//
//  ScheduledWorkoutsRowView.swift
//  Olio
//
//  Created by Jake King on 25/11/2021.
//

import SwiftUI

struct ScheduledWorkoutsRowView: View {
    @ObservedObject var workout: Workout

    var body: some View {
        VStack(alignment: .leading) {
            Text(workout.workoutName)
                .font(.title3)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity,
                       alignment: .leading)
        }
        .padding()
        .background(Color.secondarySystemGroupedBackground)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2),
                radius: 5)
    }
}

struct ScheduledWorkoutsRowView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduledWorkoutsRowView(workout: Workout.example)
    }
}
