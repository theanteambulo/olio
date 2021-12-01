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

    var workoutDates: [Date] {
        var dates = [Date]()

        for workout in sortedWorkouts {
            if !dates.contains(Calendar.current.startOfDay(for: workout.workoutDate)) {
                dates.append(Calendar.current.startOfDay(for: workout.workoutDate))
            }
        }

        return dates
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
            Group {
                if sortedWorkouts.isEmpty {
                    Text("Nothing to see here... yet!")
                } else {
                    List {
                        ForEach(workoutDates, id: \.self) { date in
                            Section(header: Text(date.formatted(date: .complete, time: .omitted))) {
                                WorkoutsListView(date: date, workouts: sortedWorkouts)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
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
