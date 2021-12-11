//
//  ExerciseHistoryRowView.swift
//  Olio
//
//  Created by Jake King on 02/12/2021.
//

import SwiftUI

/// A single row in an exercise's history representing a given completed set not part of a template workout.
struct ExerciseHistoryRowView: View {
    /// The exercise set used to construct this view.
    @ObservedObject var exerciseSet: ExerciseSet

    /// The date the exercise set was completed.
    var exerciseSetWorkoutDate: Text {
        if let workout = exerciseSet.workout {
            return Text(workout.workoutDate.formatted(date: .abbreviated, time: .omitted))
         } else {
            return Text(.workoutDateMissing)
        }
    }

    /// The name of the workout the exercise set is child of.
    var exerciseSetWorkoutName: Text {
        if let workout = exerciseSet.workout {
            return Text(workout.workoutName)
         } else {
            return Text(.workoutNameMissing)
        }
    }

    /// The number of reps completed in the exercise set.
    var exerciseSetReps: Text {
        Text("\(exerciseSet.exerciseSetReps) reps")
    }

    /// The accessibility label used for the view.
    var accessibilityLabel: Text {
        exerciseSetWorkoutName + Text(" ,") + exerciseSetWorkoutDate + Text(" ,") + exerciseSetReps
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                exerciseSetWorkoutName
                exerciseSetWorkoutDate
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            exerciseSetReps
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }
}

struct ExerciseHistoryRowView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseHistoryRowView(exerciseSet: ExerciseSet.example)
    }
}
