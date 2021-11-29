//
//  HistoryView.swift
//  Olio
//
//  Created by Jake King on 23/11/2021.
//

import CoreData
import SwiftUI

struct HistoryView: View {
    let workoutsCompleted: FetchRequest<Workout>
    let showCompletedWorkouts: Bool

    static let tag: String? = "History"

    init(showCompletedWorkouts: Bool) {
        self.showCompletedWorkouts = showCompletedWorkouts

        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        let completedPredicate = NSPredicate(format: "completed = true")
        request.predicate = NSCompoundPredicate(type: .and,
                                                subpredicates: [completedPredicate])

        request.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.dateCompleted,
                                                    ascending: true)]

        workoutsCompleted = FetchRequest(fetchRequest: request)
    }

    var body: some View {
        NavigationView {
            List {
                WorkoutListView(workouts: workoutsCompleted,
                            showingScheduledWorkouts: false)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("History")
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
