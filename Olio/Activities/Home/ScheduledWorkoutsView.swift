//
//  ScheduledWorkoutsView.swift
//  Olio
//
//  Created by Jake King on 25/11/2021.
//

import SwiftUI

struct ScheduledWorkoutsView: View {
    let title: LocalizedStringKey

    let scheduledWorkouts: FetchedResults<Workout>

    var body: some View {
        if scheduledWorkouts.isEmpty {
            EmptyView()
        } else {
            Text(title)
                .font(.headline)

            ForEach(scheduledWorkouts) { workout in
                Section(header: Text(workout.formattedWorkoutDateScheduled)) {
                    NavigationLink(destination: EditWorkoutView(workout: workout)) {
                            ScheduledWorkoutsRowView(workout: workout)
                    }
                }
            }
            .padding(.top)
        }
    }
}
