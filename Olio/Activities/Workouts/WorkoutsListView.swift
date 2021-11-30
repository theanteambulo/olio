//
//  WorkoutsListView.swift
//  Olio
//
//  Created by Jake King on 30/11/2021.
//

import SwiftUI

struct WorkoutsListView: View {
    let workouts: [Workout]

    @EnvironmentObject var dataController: DataController

    var workoutDates: [Date] {
        var dates = [Date]()

        for workout in workouts {
            if !dates.contains(Calendar.current.startOfDay(for: workout.workoutDate)) {
                dates.append(Calendar.current.startOfDay(for: workout.workoutDate))
            }
        }

        return dates
    }

    var body: some View {
        if workouts.isEmpty {
            Text("Nothing to see here... yet!")
        } else {
            List {
                ForEach(workoutDates, id: \.self) { date in
                    Section(header: Text(date.formatted(date: .complete, time: .omitted))) {
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
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
    }

    func filterWorkoutsByDate(_ date: Date,
                              workouts: [Workout]) -> [Workout] {
        return workouts.filter { Calendar.current.startOfDay(for: $0.workoutDate) == date }
    }
}

struct WorkoutsListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsListView(workouts: [Workout.example])
    }
}
