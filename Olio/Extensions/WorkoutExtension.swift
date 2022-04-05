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

    /// Combines workout and exercise data to create CloudKit records.
    /// - Returns: An array of CloudKit records.
    func prepareCloudRecords(owner: String) -> [CKRecord] {
        var allRecords = [CKRecord]()

        let workoutRecordName = objectID.uriRepresentation().absoluteString
        let workoutRecordID = CKRecord.ID(recordName: workoutRecordName)
        let workoutRecord = CKRecord(recordType: "Workout", recordID: workoutRecordID)
        workoutRecord["workoutName"] = workoutName
        workoutRecord["owner"] = owner

        workoutExercises.forEach { exercise in
            let exerciseRecordName = exercise.objectID.uriRepresentation().absoluteString
            let exerciseRecordID = CKRecord.ID(recordName: exerciseRecordName)
            let exerciseRecord = CKRecord(recordType: "Exercise", recordID: exerciseRecordID)
            exerciseRecord["exerciseName"] = exercise.exerciseName
            exerciseRecord["category"] = exercise.exerciseCategory
            exerciseRecord["muscleGroup"] = exercise.exerciseMuscleGroup

            let workoutExerciseSets = exercise.exerciseSets.filter({ $0.workout == self })

            exerciseRecord["setCount"] = workoutExerciseSets.count
            exerciseRecord["targetReps"] = workoutExerciseSets.map({ $0.exerciseSetReps }).max() ?? 0
            exerciseRecord["targetWeight"] = workoutExerciseSets.map({ $0.exerciseSetWeight }).max() ?? 0

            if let workoutExercisePlacement = exercise.exercisePlacements.filter({ $0.workout == self }).first {
                exerciseRecord["exercisePlacement"] = workoutExercisePlacement.placementIndexPosition
            }

            exerciseRecord["workout"] = CKRecord.Reference(recordID: workoutRecordID, action: .deleteSelf)

            allRecords.append(exerciseRecord)
        }

        allRecords.append(workoutRecord)

        return allRecords
    }
}
