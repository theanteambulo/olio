//
//  WorkoutExtension.swift
//  Olio
//
//  Created by Jake King on 23/11/2021.
//

import CloudKit
import Foundation
import SwiftUI
import CoreHaptics

extension Workout {
    /// The unwrapped id property of a workout.
    var workoutId: String {
        id?.uuidString ?? ""
    }

    /// The unwrapped name property of a workout.
    var workoutName: String {
        template
        ? name ?? NSLocalizedString("newTemplate",
                                    comment: "Create a new template")
        : name ?? NSLocalizedString("newWorkout",
                                    comment: "Create a new workout")
    }

    /// The unwrapped date property of a workout indicating the date on which the workout is scheduled.
    var workoutDate: Date {
        date ?? Date()
    }

    /// The unwrapped created date property of a workout indicating the date the workout was created.
    var workoutCreatedOn: Date {
        createdDate ?? Date()
    }

    /// The unwrapped date property of a workout formatter as a string.
    var formattedWorkoutDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: workoutDate)
    }

    /// The unwrapped exercises a workout is parent of.
    var workoutExercises: [Exercise] {
        exercises?.allObjects as? [Exercise] ?? []
    }

    /// The unwrapped exercise sets a workout is parent of.
    var workoutExerciseSets: [ExerciseSet] {
        sets?.allObjects as? [ExerciseSet] ?? []
    }

    /// The unwrapped placements a workout is parent of.
    var workoutPlacements: [Placement] {
        placements?.allObjects as? [Placement] ?? []
    }

    /// An example workout for previewing purposes.
    static var example: Workout {
        let dataController = DataController.preview
        let viewContext = dataController.container.viewContext

        let workout = Workout(context: viewContext)
        workout.name = "Example Workout"
        workout.date = Date.now
        workout.createdDate = Date.now
        workout.completed = true
        workout.template = false

        return workout
    }

    /// Derives the title of an alert displayed when a user completes or schedules a workout.
    ///
    /// Conditional on whether the workout is already complete or not.
    /// - Parameter workout: The workout being completed or scheduled.
    /// - Returns: A LocalizedStringKey corresponding to the action taken on the workout (i.e. complete or schedule).
    func getConfirmationAlertTitle(workout: Workout) -> LocalizedStringKey {
        return workout.completed
        ? Strings.workoutScheduledAlertTitle.localized
        : Strings.workoutCompletedAlertTitle.localized
    }

    /// Derives the message of an alert displayed when a user completes or schedules a workout.
    /// - Parameter workout: The workout being completed or scheduled.
    /// - Returns: A LocalizedStringKey corresponding to the action taken on the workout (i.e. complete or schedule).
    func getConfirmationAlertMessage(workout: Workout) -> LocalizedStringKey {
        if workout.completed {
            return Strings.workoutScheduledAlertMessage.localized
        } else {
            return Strings.workoutCompletedAlertMessage.localized
        }
    }

    func getWorkoutColors() -> [Color] {
        var workoutColors = [Color]()

        for exercise in workoutExercises {
            workoutColors.append(exercise.getExerciseCategoryColor())
        }

        workoutColors.removeDuplicates()

        return workoutColors
    }

    /// Converts all workout data into CloudKit records.
    /// - Returns: An array of CloudKit records.
    func prepareCloudRecords() -> [CKRecord] {
        var allRecords = [CKRecord]()

        // Create a parent record (Workout)
        let workoutRecordName = objectID.uriRepresentation().absoluteString
        let workoutRecordID = CKRecord.ID(recordName: workoutRecordName)
        let workoutRecord = CKRecord(recordType: "Workout", recordID: workoutRecordID)
        workoutRecord["name"] = workoutName
        workoutRecord["date"] = workoutDate
        workoutRecord["owner"] = "theAnteambulo"
        workoutRecord["template"] = template

        workoutExercises.forEach { exercise in
            // Create parent records (Exercise)
            let exerciseRecordName = exercise.objectID.uriRepresentation().absoluteString
            let exerciseRecordID = CKRecord.ID(recordName: exerciseRecordName)
            let exerciseRecord = CKRecord(recordType: "Exercise", recordID: exerciseRecordID)
            exerciseRecord["name"] = exercise.exerciseName
            exerciseRecord["category"] = exercise.category
            exerciseRecord["muscleGroup"] = exercise.muscleGroup

            // Create child records (WorkoutExercise)
            let workoutExerciseRecordName = workoutRecordName + exerciseRecordName
            let workoutExerciseRecordID = CKRecord.ID(recordName: workoutExerciseRecordName)
            let workoutExerciseRecord = CKRecord(recordType: "WorkoutExercise", recordID: workoutExerciseRecordID)
            workoutExerciseRecord["workout"] = CKRecord.Reference(recordID: workoutRecordID, action: .none)
            workoutExerciseRecord["exercise"] = CKRecord.Reference(recordID: exerciseRecord.recordID, action: .none)

            if let workoutExercisePlacement = exercise.exercisePlacements.filter({ $0.workout == self }).first {
                workoutExerciseRecord["exercisePlacement"] = workoutExercisePlacement.placementIndexPosition
            }

            allRecords.append(exerciseRecord)
            allRecords.append(workoutExerciseRecord)

            // Create a child record (Exercise Sets)
            exercise.exerciseSets.forEach { exerciseSet in
                let exerciseSetRecordName = exerciseSet.objectID.uriRepresentation().absoluteString
                let exerciseSetRecordID = CKRecord.ID(recordName: exerciseSetRecordName)
                let exerciseSetRecord = CKRecord(recordType: "ExerciseSet", recordID: exerciseSetRecordID)
                exerciseSetRecord["workout"] = CKRecord.Reference(recordID: workoutRecordID, action: .deleteSelf)
                exerciseSetRecord["exercise"] = CKRecord.Reference(recordID: exerciseRecordID, action: .deleteSelf)
                exerciseSetRecord["weight"] = exerciseSet.exerciseSetWeight
                exerciseSetRecord["reps"] = exerciseSet.exerciseSetReps
                exerciseSetRecord["distance"] = exerciseSet.exerciseSetDistance
                exerciseSetRecord["duration"] = exerciseSet.exerciseSetDuration
                exerciseSetRecord["completed"] = exerciseSet.completed

                allRecords.append(exerciseSetRecord)
            }
        }

        allRecords.append(workoutRecord)

        allRecords.forEach { record in
            print("\(record)\n")
        }

        return allRecords
    }
}
