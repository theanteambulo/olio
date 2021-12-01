//
//  WorkoutsListView.swift
//  Olio
//
//  Created by Jake King on 30/11/2021.
//

import SwiftUI

struct WorkoutsListView: View {
    let date: Date
    let workouts: [Workout]

    @EnvironmentObject var dataController: DataController

    var body: some View {
        ForEach(filterWorkoutsByDate(date,
                                     workouts: workouts)) { workout in
            WorkoutRowView(workout: workout)
        }
        .onDelete { offsets in
            let allWorkouts = filterWorkoutsByDate(date,
                                                   workouts: workouts)

            for offset in offsets {
                withAnimation {
                    let workoutToDelete = allWorkouts[offset]
                    dataController.delete(workoutToDelete)
                }
            }

            dataController.save()
        }
    }

    func filterWorkoutsByDate(_ date: Date,
                              workouts: [Workout]) -> [Workout] {
        return workouts.filter { Calendar.current.startOfDay(for: $0.workoutDate) == date }
    }
}

struct WorkoutsListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsListView(date: Date(), workouts: [Workout.example])
    }
}
