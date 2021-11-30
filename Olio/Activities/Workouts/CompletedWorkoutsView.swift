//
//  CompletedWorkoutsView.swift
//  Olio
//
//  Created by Jake King on 30/11/2021.
//

import CoreData
import SwiftUI

struct CompletedWorkoutsView: View {
    let workouts: FetchRequest<Workout>

    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var managedObjectContext

    static let historyTag: String? = "History"

    var sortedWorkouts: [Workout] {
        return workouts.wrappedValue.sorted { first, second in
            if first.workoutDate < second.workoutDate {
                return true
            } else if first.workoutDate > second.workoutDate {
                return false
            }

            return first.workoutName < second.workoutName
        }
    }

    init() {
        let workoutsRequest: NSFetchRequest<Workout> = Workout.fetchRequest()

        let completedPredicate = NSPredicate(format: "completed = true")
        workoutsRequest.predicate = NSCompoundPredicate(type: .and,
                                                        subpredicates: [completedPredicate])
        workoutsRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Workout.date,
                             ascending: true),
            NSSortDescriptor(keyPath: \Workout.name,
                             ascending: true)
        ]

        workoutsRequest.fetchLimit = 10

        workouts = FetchRequest(fetchRequest: workoutsRequest)
    }

    var body: some View {
        NavigationView {
            WorkoutsListView(workouts: sortedWorkouts)
                .padding(.bottom)
                .navigationTitle("History")
        }
    }
}

struct CompletedWorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        CompletedWorkoutsView()
    }
}
