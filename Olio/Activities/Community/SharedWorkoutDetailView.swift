//
//  SharedWorkoutDetailView.swift
//  Olio
//
//  Created by Jake King on 24/03/2022.
//

import CloudKit
import CoreData
import SwiftUI

struct SharedWorkoutDetailView: View {
    let workout: SharedWorkout

    /// The environment singleton responsible for managing the Core Data stack.
    @EnvironmentObject var dataController: DataController

    /// The object space in which all managed objects exist.
    @Environment(\.managedObjectContext) var managedObjectContext
    /// Allows for the view to be dismissed programmatically.
    @Environment(\.dismiss) var dismiss

    @State private var exercises = [SharedExercise]()
    @State private var exercisesLoadState = LoadState.inactive

    var downloadToolbarButton: some View {
        Button {
            // Display an alert asking if the user wants to download this workout as a template
            // On confirmation
            // Get all exercises from the user's library

            let existingExercises = getExistingExercises()

            let exercisesToDownloadIDs = exercises.map({ $0.id })
            let exercisesToDownload = transformStrings(exercises.map({ $0.name }))

            var exercisesToDownloadDictionary: [String: String] = Dictionary(
                uniqueKeysWithValues: zip(exercisesToDownloadIDs, exercisesToDownload))

            exercisesToDownloadDictionary["-1"] = "TESTEXERCISENAMEREMOVETHISAFTERDEV"

            let diff = exercisesToDownloadDictionary.values.filter({ !existingExercises.values.contains($0) })

            print(exercisesToDownloadDictionary.first(where: { $0.value == diff[0] }) ?? "1")

            // If diff is not empty...
                // Find the key associated with that value
                // Find the exercise in the exercisesToDownload array whose ID matches that key
                // Get the details about the exercise to download
                    // category
                    // muscleGroup
                    // setCount
                    // targetReps
                    // targetWeight
                // Create a new Core Data exercise

            // If diff is empty...
                // All good! Crack on.

            // Create a workout
            // Add exercises to that workout - HOW?!?!?!
            // Create sets for that workout - HOW?!?!?!
            // Confirm to the user that the download is complete - start simple and show an alert

        } label: {
            Label(Strings.downloadWorkout.localized, systemImage: "icloud.and.arrow.down")
        }
    }

    var sharedExerciseList: some View {
        List {
            ForEach(exercises) { exercise in
                SharedExerciseRowView(sharedExercise: exercise)
            }
            .listStyle(InsetGroupedListStyle())
        }
    }

    var body: some View {
        VStack {
            Form {
                Section(header: Text(.creator)) {
                    Text("\(workout.owner)")
                        .font(.headline)
                }

                Section(header: Text(.exercisesTab)) {
                    switch exercisesLoadState {
                    case .inactive, .loading:
                        ProgressView()
                    case .noResults:
                        Text(.noExercises)
                    case .success:
                        sharedExerciseList
                    }
                }
            }
            .navigationTitle(workout.name)
            .toolbar {
                downloadToolbarButton
            }
            .onAppear {
                fetchSharedExercises(workout: workout)
            }
        }
    }

    func getExistingExercises() -> [String: String] {
        let existingExercisesRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        existingExercisesRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.name, ascending: true)]

        do {
            let existingExercises = try managedObjectContext.fetch(existingExercisesRequest)
            let existingExerciseIDs = existingExercises.map({ $0.exerciseId })
            let existingExerciseNames = existingExercises.map({ $0.exerciseName })

            let existingExercisesDictionary: [String: String] = Dictionary(
                uniqueKeysWithValues: zip(existingExerciseIDs, transformStrings(existingExerciseNames)))

            return existingExercisesDictionary
        } catch {
            return ["": ""]
        }
    }

    func transformStrings(_ stringArray: [String]) -> [String] {
        Array(stringArray.map({
            $0.filter("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".contains).uppercased()
        }).removingDuplicates())
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
                let name = record["exerciseName"] as? String ?? Strings.unknownExercise.localized.stringKey
                let category = record["category"] as? String ?? Strings.unknownCategory.localized.stringKey
                let muscleGroup = record["muscleGroup"] as? String ?? Strings.unknownMuscleGroup.localized.stringKey
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
