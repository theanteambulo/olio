//
//  ExerciseHistoryRowView.swift
//  Olio
//
//  Created by Jake King on 02/12/2021.
//

import SwiftUI

struct ExerciseHistoryRowView: View {
    @ObservedObject var exerciseSet: ExerciseSet

    var exerciseSetWorkoutDate: Text {
        if let workout = exerciseSet.workout {
            return Text(workout.workoutDate.formatted(date: .abbreviated, time: .omitted))
         } else {
            return Text(.workoutDateMissing)
        }
    }

    var exerciseSetWorkoutName: Text {
        if let workout = exerciseSet.workout {
            return Text(workout.workoutName)
         } else {
            return Text(.workoutNameMissing)
        }
    }

    var exerciseSetReps: Text {
        Text("\(exerciseSet.exerciseSetReps) reps")
    }

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
