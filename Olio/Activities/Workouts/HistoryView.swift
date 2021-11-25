//
//  HistoryView.swift
//  Olio
//
//  Created by Jake King on 23/11/2021.
//

import SwiftUI

struct HistoryView: View {
    let workouts: FetchRequest<Workout>
    let showCompletedWorkouts: Bool

    static let tag: String? = "History"

    init(showCompletedWorkouts: Bool) {
        self.showCompletedWorkouts = showCompletedWorkouts

        workouts = FetchRequest<Workout>(
            entity: Workout.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Workout.dateCompleted,
                                               ascending: false)],
            predicate: NSPredicate(format: "completed = %d", showCompletedWorkouts)
        )
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(workouts.wrappedValue) { workout in
                    Section(header: Text(workout.formattedWorkoutDateCompleted)) {
                        WorkoutRowView(workout: workout)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        HistoryView(showCompletedWorkouts: true)
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
