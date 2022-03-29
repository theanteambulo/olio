//
//  SharedWorkoutDetailView.swift
//  Olio
//
//  Created by Jake King on 24/03/2022.
//

import CloudKit
import SwiftUI

struct SharedWorkoutDetailView: View {
    let workout: SharedWorkout

    @State private var exercises = [SharedExercise]()
    @State private var exercisesLoadState = LoadState.inactive

    var body: some View {
        // Make this similar to EditWorkoutView?
        List {
            Section {
                switch exercisesLoadState {
                case .inactive, .loading:
                    ProgressView()
                case .noResults:
                    Text("No exercises")
                case .success:
                    ForEach(exercises) { exercise in
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                Text("\(exercise.category) | \(exercise.muscleGroup)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 2)

                                Text("\(exercise.name)")
                                    .font(.headline)
                            }

                            HStack {
                                Spacer()

                                VStack {
                                    Text("Target Reps: \(exercise.targetReps)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Text("Target Weight: \(bodyweightExerciseWeight(forExercise: exercise))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Text("Target Sets: \(exercise.setCount)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(workout.name)
        .onAppear {
            fetchSharedExercises(workout: workout)
        }
    }

    func bodyweightExerciseWeight(forExercise exercise: SharedExercise) -> Text {
        if exercise.category == "Body" {
            return Text("N/A")
        } else {
            return Text("\(exercise.targetWeight, specifier: "%.2f")kg")
        }
    }

    // swiftlint:disable:next function_body_length
    func fetchSharedExercises(workout: SharedWorkout) {
        // Ensure the method is only run once
        guard exercisesLoadState == .inactive else { return }
        exercisesLoadState = .loading

        // Tell CloudKit what we need
        let workoutRecordID = CKRecord.ID(recordName: workout.id)
        let workoutReference = CKRecord.Reference(recordID: workoutRecordID, action: .none)
        let exercisePredicate = NSPredicate(format: "workout == %@", workoutReference)
        let sortDescriptor = NSSortDescriptor(key: "exercisePlacement", ascending: true)
        let exercisesQuery = CKQuery(recordType: "Exercise", predicate: exercisePredicate)
        exercisesQuery.sortDescriptors = [sortDescriptor]

        // Create operation to say what aspects of the data we want
        let operation = CKQueryOperation(query: exercisesQuery)
        operation.desiredKeys = [
            "exerciseName",
            "category",
            "muscleGroup",
            "exercisePlacement",
            "setCount",
            "targetReps",
            "targetWeight"
        ]
        operation.resultsLimit = 50

        // Fetch records from CloudKit
        operation.recordMatchedBlock = { _, result in
            switch result {
            case .success(let record):
                let id = record.recordID.recordName
                let name = record["exerciseName"] as? String ?? "Unknown Exercise"
                let category = record["category"] as? String ?? "Unknown Category"
                let muscleGroup = record["muscleGroup"] as? String ?? "Unknown Muscle Group"
                let placement = record["exercisePlacement"] as? Int ?? 0
                let setCount = record["setCount"] as? Int ?? 0
                let targetReps = record["targetReps"] as? Int ?? 0
                let targetWeight = record["targetWeight"] as? Double ?? 0

                let sharedExercise = SharedExercise(
                    id: id,
                    name: name,
                    category: category,
                    muscleGroup: muscleGroup,
                    placement: placement,
                    setCount: setCount,
                    targetReps: targetReps,
                    targetWeight: targetWeight
                )

                exercises.append(sharedExercise)
                exercisesLoadState = .success
                print("Success: \(sharedExercise)")
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }

        // Called when all records fetched
        operation.queryResultBlock = { result in
            switch result {
            case .success:
                if exercises.isEmpty {
                    exercisesLoadState = .noResults
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }

        // Send operation to CloudKit
        CKContainer.default().publicCloudDatabase.add(operation)
    }
}

struct SharedWorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SharedWorkoutDetailView(workout: SharedWorkout.example)
    }
}
