//
//  SharedWorkoutDetailView.swift
//  Olio
//
//  Created by Jake King on 24/03/2022.
//

import CloudKit
import CoreData
import SwiftUI

// swiftlint:disable:next type_body_length
struct SharedWorkoutDetailView: View {
    let workout: SharedWorkout

    /// The environment singleton responsible for managing the Core Data stack.
    @EnvironmentObject var dataController: DataController

    /// The object space in which all managed objects exist.
    @Environment(\.managedObjectContext) var managedObjectContext
    /// Allows for the view to be dismissed programmatically.
    @Environment(\.dismiss) var dismiss

    /// Stores the user's username.
    @AppStorage("username") var username: String?

    /// Checks whether the onboarding journey should be showing.
    ///
    /// Should always be false in this view. Used in onboarding journey for showing SIWA sheet.
    @AppStorage("userOnboarded") var showingOnboardingJourney: Bool = false

    @State private var messages = [ChatMessage]()
    @State private var newChatMessageText = ""

    @State private var exercises = [SharedExercise]()
    @State private var exercisesLoadState = LoadState.inactive
    @State private var messagesLoadState = LoadState.inactive
    @State private var showingDownloadWorkoutAlert = false
    @State private var showingDownloadCompleteAlert = false
    @State private var showingSignInWithAppleSheet = false
    @State private var cloudError: CloudError?

    var downloadToolbarButton: some View {
        Button {
            showingDownloadWorkoutAlert = true
        } label: {
            Label(Strings.downloadWorkout.localized, systemImage: "icloud.and.arrow.down")
        }
        .alert(Strings.downloadWorkout.localized,
               isPresented: $showingDownloadWorkoutAlert) {
            Button(Strings.confirmButton.localized) {
                downloadWorkoutAsTemplate()
            }

            Button(Strings.cancelButton.localized, role: .cancel) { }
        } message: {
            Text(.downloadWorkoutMessage)
        }
        .alert(Strings.downloadComplete.localized,
               isPresented: $showingDownloadCompleteAlert) {
            Button(Strings.okButton.localized) { }
        }
        .alert(item: $cloudError) { error in
            Alert(
                title: Text(.error),
                message: Text(error.localizedMessage)
            )
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

    @ViewBuilder var messagesFooter: some View {
        if username == nil {
            Button(Strings.signInToComment.localized, action: signIn)
                .frame(maxWidth: .infinity)
        } else {
            VStack {
                TextField(Strings.enterYourMessage.localized,
                          text: $newChatMessageText)
                    .frame(maxWidth: .infinity, minHeight: 104)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textCase(nil)

                Button(action: sendChatMessage) {
                    Text(.sendButton)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .contentShape(Capsule())
                }
            }
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

                Section(header: Text(.discussion),
                        footer: messagesFooter) {
                    if messagesLoadState == .success {
                        ForEach(messages) { message in
                            VStack(alignment: .leading) {
                                Text("\(message.from)")
                                    .font(.caption.bold())
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 2)

                                Text("\(message.text)")
                                    .multilineTextAlignment(.leading)

                                HStack {
                                    Spacer()

                                    VStack(alignment: .trailing) {
                                        Text("\(messageSendTime(message))")
                                            .font(.caption)

                                        Text("\(message.date.formatted(date: .abbreviated, time: .omitted))")
                                            .font(.caption)
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSignInWithAppleSheet) {
                SignInView(showingOnboardingJourney: $showingOnboardingJourney)
            }
            .navigationTitle(workout.name)
            .toolbar {
                downloadToolbarButton
            }
            .onAppear {
                fetchSharedExercises(workout: workout)
                fetchChatMessages()
            }
        }
    }

    /// Starts the Sign In With Apple process.
    func signIn() {
        showingSignInWithAppleSheet = true
    }

    /// Formats a message send time depending on whether it was send today or not.
    /// - Parameter message: The message whose time needs to be formatted.
    /// - Returns: The formatted time as a string.
    func messageSendTime(_ message: ChatMessage) -> String {
        let sendTime = message.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: sendTime)
    }

    /// Sends a chat message to iCloud.
    func sendChatMessage() {
        let text = newChatMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.count > 2 else { return }
        guard let username = username else { return }

        let message = CKRecord(recordType: "Message")
        message["from"] = username
        message["text"] = text

        let workoutID = CKRecord.ID(recordName: workout.id)
        message["workout"] = CKRecord.Reference(recordID: workoutID, action: .deleteSelf)

        let backupText = newChatMessageText
        newChatMessageText = ""

        CKContainer.default().publicCloudDatabase.save(message) { record, error in
            if let error = error {
                cloudError = error.getCloudKitError()
                newChatMessageText = backupText
            } else if let record = record {
                let message = ChatMessage(from: record)
                messages.append(message)
                messagesLoadState = .success
            }
        }
    }

    func fetchChatMessages() {
        guard messagesLoadState == .inactive else { return }
        messagesLoadState = .loading

        let workoutRecordID = CKRecord.ID(recordName: workout.id)
        let reference = CKRecord.Reference(recordID: workoutRecordID, action: .none)
        let predicate = NSPredicate(format: "workout == %@", reference)
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        let query = CKQuery(recordType: "message", predicate: predicate)
        query.sortDescriptors = [sortDescriptor]

        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["from", "text"]

        operation.recordMatchedBlock = { _, result in
            switch result {
            case .success(let record):
                let message = ChatMessage(from: record)
                messages.append(message)
                messagesLoadState = .success
            case .failure(let error):
                cloudError = error.getCloudKitError()
            }
        }

        operation.queryResultBlock = { result in
            switch result {
            case .success:
                if messages.isEmpty {
                    messagesLoadState = .noResults
                }
            case .failure(let error):
                cloudError = error.getCloudKitError()
            }
        }

        CKContainer.default().publicCloudDatabase.add(operation)
    }

    /// Performs a fetch request to return all the Exercise objects existing in the user's library.
    /// - Returns: An array of Exercise objects.
    func getExistingExercises() -> [Exercise] {
        let existingExercisesRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        existingExercisesRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.name, ascending: true)]

        do {
            let existingExercises = try managedObjectContext.fetch(existingExercisesRequest)

            return existingExercises
        } catch {
            return []
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
            case .failure(let error):
                cloudError = error.getCloudKitError()
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
                cloudError = error.getCloudKitError()
            }
        }

        // Send operation to CloudKit
        CKContainer.default().publicCloudDatabase.add(operation)
    }

    // swiftlint:disable:next function_body_length
    func downloadWorkoutAsTemplate() {
        var CDExercises = getExistingExercises()
        var CDExerciseDictionary = transformExercises(CDExercises)

        let CKExerciseDictionary: [String: String] = Dictionary(
            uniqueKeysWithValues: zip(
                exercises.map({ $0.id }),
                removeAllNonAlphabeticCharactersForEachElement(exercises.map({ $0.name }))
            )
        )

        // Filter CDExerciseDictionary and return any pairs whose equivalent CD exercises already exist
        let noNeedToDownload = CKExerciseDictionary.filter({ CDExerciseDictionary.values.contains($0.value) })

        // Filter CDExerciseDictionary and return any pairs whose equivalent CD exercises don't already exist
        let needToDownload = CKExerciseDictionary.filter({ !CDExerciseDictionary.values.contains($0.value) })

        // Create a dictionary with pairs consisting of the CD exerciseId and the CK exerciseId with matching names
        var CDCKExerciseMapping = [String: String]()

        noNeedToDownload.forEach { pair in
            if let CDExerciseID = CDExerciseDictionary.first(where: { $0.value == pair.value })?.key {
                CDCKExerciseMapping[CDExerciseID] = pair.key
            }
        }

        if !needToDownload.isEmpty {
            needToDownload.forEach { pair in
                // Find the SharedExercise instance with the CK exercise key
                guard let sharedExercise = exercises.first(where: { $0.id == pair.key }) else {
                    return
                }

                // Create a new CD exercise
                let newExercise = Exercise(context: dataController.container.viewContext)
                newExercise.id = UUID()
                newExercise.name = sharedExercise.name
                newExercise.category = getExerciseCategory(sharedExercise.category)
                newExercise.muscleGroup = getExerciseMuscleGroup(sharedExercise.muscleGroup)

                // Add the CD exercise to helper arrays/dictionaries
                CDExercises.append(newExercise)
                CDExerciseDictionary[newExercise.exerciseId] = newExercise.exerciseName
                CDCKExerciseMapping[newExercise.exerciseId] = pair.key
            }
        }

        // Create a workout
        let newWorkout = Workout(context: dataController.container.viewContext)
        newWorkout.id = UUID()
        newWorkout.name = workout.name
        newWorkout.date = Date.now
        newWorkout.createdDate = Date.now
        newWorkout.completed = false
        newWorkout.template = true

        // Create an array of CD exercises to be added to the workout later
        let workoutExerciseIDs = CDExerciseDictionary.filter({
            let exerciseNameNormalized = removeAllNonAlphabeticCharactersFromString($0.value)
            return CKExerciseDictionary.values.contains(exerciseNameNormalized)
        })

        let workoutExercises = CDExercises.filter({ workoutExerciseIDs.keys.contains($0.exerciseId) })

        // Create sets and placements for each exercise
        CDCKExerciseMapping.forEach { pair in
            // Get the SharedExercise object
            let sharedExercise = exercises.filter({ $0.id == pair.value }).first

            // Get the CD exercise object
            let newExercise = workoutExercises.filter({ $0.exerciseId == pair.key }).first

            // Use properties of the SharedExercise object to create exercise sets with the desired attributes
            let targetSets = sharedExercise?.setCount ?? 3

            for _ in 0..<targetSets {
                // Create a new ExerciseSet
                let newExerciseSet = ExerciseSet(context: dataController.container.viewContext)
                newExerciseSet.id = UUID()
                newExerciseSet.creationDate = Date()
                newExerciseSet.completed = true
                newExerciseSet.workout = newWorkout
                newExerciseSet.exercise = newExercise
                newExerciseSet.reps = Int16(sharedExercise?.targetReps ?? 10)
                newExerciseSet.weight = Double(sharedExercise?.targetWeight ?? 10)

                // Add the new ExerciseSet
                newWorkout.addToSets(newExerciseSet)
            }

            // Create a new Placement
            let newPlacement = Placement(context: dataController.container.viewContext)
            newPlacement.id = UUID()
            newPlacement.workout = newWorkout
            newPlacement.exercise = newExercise
            newPlacement.indexPosition = Int16(sharedExercise?.placement ?? 0)

            // Add the new Placement
            newWorkout.addToPlacements(newPlacement)
        }

        // Add the Exercises
        newWorkout.addToExercises(NSSet(array: workoutExercises))

        // Save all changes
        dataController.save()

        showingDownloadCompleteAlert = true
    }

    /// Creates a dictionary where key-value pairs consist of an Exercise object's ID and name, each as a string.
    /// - Parameter exerciseArray: The array of Exercise objects to transform.
    /// - Returns: A dictionary where keys and values are both strings.
    func transformExercises(_ exerciseArray: [Exercise]) -> [String: String] {
        let existingExerciseIDs = exerciseArray.map({ $0.exerciseId })
        let existingExerciseNames = exerciseArray.map({ $0.exerciseName })

        let exerciseDictionary: [String: String] = Dictionary(
            uniqueKeysWithValues: zip(
                existingExerciseIDs,
                removeAllNonAlphabeticCharactersForEachElement(existingExerciseNames)
            )
        )

        return exerciseDictionary
    }

    /// Transforms each element of an array of strings by removing any non-alphabetic character.
    /// - Parameter stringArray: The array of strings to be transformed.
    /// - Returns: The transformed array of strings.
    func removeAllNonAlphabeticCharactersForEachElement(_ stringArray: [String]) -> [String] {
        Array(stringArray.map({
            removeAllNonAlphabeticCharactersFromString($0)
        }).removingDuplicates())
    }

    /// Transforms a string by removing any non-alphabetic character.
    /// - Parameter string: The string to be transformed.
    /// - Returns: The transformed string.
    func removeAllNonAlphabeticCharactersFromString(_ string: String) -> String {
        return string.filter("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".contains).uppercased()
    }

    /// Gets the corresponding numeric value for a given exercise category for compatibility with the Core Data.
    /// - Parameter category: An exercise category expressed as a string.
    /// - Returns: An integer corresponding to the exercise category.
    func getExerciseCategory(_ category: String) -> Int16 {
        switch category {
        case "Free Weights":
            return 1
        case "Bodyweight":
            return 2
        default:
            return -1
        }
    }

    /// Gets the corresponding numeric value for a given muscle group for compatibility with Core Data.
    /// - Parameter muscleGroup: A muscle group expressed as a string.
    /// - Returns: An integer corresponding to the muscle group.
    func getExerciseMuscleGroup(_ muscleGroup: String) -> Int16 {
        switch muscleGroup {
        case "Chest":
            return 1
        case "Back":
            return 2
        case "Shoulders":
            return 3
        case "Biceps":
            return 4
        case "Triceps":
            return 5
        case "Legs":
            return 6
        case "Abs":
            return 7
        case "Full Body":
            return 8
        default:
            return -1
        }
    }
}

struct SharedWorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SharedWorkoutDetailView(workout: SharedWorkout.example)
    }
// swiftlint:disable:next file_length
}
