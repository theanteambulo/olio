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
        let templatePredicate = NSPredicate(format: "template =  false")
        let completedPredicate = NSPredicate(format: "completed = false")
        request.predicate = NSCompoundPredicate(type: .and,
                                                subpredicates: [templatePredicate, completedPredicate])

        request.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.dateCompleted,
                                                    ascending: false)]

        workoutsCompleted = FetchRequest(fetchRequest: request)
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(workoutsCompleted.wrappedValue) { workout in
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
