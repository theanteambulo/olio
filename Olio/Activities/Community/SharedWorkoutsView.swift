//
//  SharedWorkoutsView.swift
//  Olio
//
//  Created by Jake King on 22/03/2022.
//

import CloudKit
import SwiftUI

struct SharedWorkoutsView: View {
    static let tag: String? = "Community"

    @State private var workouts = [SharedWorkout]()
    @State private var loadState = LoadState.inactive

    var body: some View {
        NavigationView {
            Group {
                switch loadState {
                case .inactive, .loading:
                    ProgressView()
                case .noResults:
                    Text("No results")
                case .success:
                    List(workouts) { workout in
                        NavigationLink(destination: SharedWorkoutDetailView(workout: workout)) {
                            VStack(alignment: .leading) {
                                Text(workout.name)
                                    .font(.headline)
                                Text(workout.owner)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Shared Workouts")
        }
        .onAppear(perform: fetchSharedWorkouts)
    }

    func fetchSharedWorkouts() {
        // Ensure the method is only run once
        guard loadState == .inactive else { return }
        loadState = .loading

        // Tell CloudKit what we need
        let predicate = NSPredicate(value: true)
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        let query = CKQuery(recordType: "Workout", predicate: predicate)
        query.sortDescriptors = [sortDescriptor]

        // Create operation to say what aspects of the data we want
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["workoutName", "owner"]
        operation.resultsLimit = 50

        // Fetch records from CloudKit
        operation.recordMatchedBlock = { _, result in
            switch result {
            case .success(let record):
                let id = record.recordID.recordName
                let name = record["workoutName"] as? String ?? "No name"
                let owner = record["owner"] as? String ?? "Unknown owner"

                let sharedWorkout = SharedWorkout(id: id, name: name, owner: owner)
                workouts.append(sharedWorkout)
                loadState = .success
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }

        // Called when all records fetched
        operation.queryResultBlock = { result in
            switch result {
            case .success:
                if workouts.isEmpty {
                    loadState = .noResults
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }

        // Send operation to CloudKit
        CKContainer.default().publicCloudDatabase.add(operation)
    }
}

struct SharedWorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        SharedWorkoutsView()
    }
}
