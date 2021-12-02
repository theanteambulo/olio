//
//  ExerciseHistoryRowView.swift
//  Olio
//
//  Created by Jake King on 02/12/2021.
//

import SwiftUI

struct ExerciseHistoryRowView: View {
    @ObservedObject var exerciseSet: ExerciseSet

    var exerciseSetWorkoutDate: some View {
        if let workout = exerciseSet.workout {
            return Text(workout.workoutDate.formatted(date: .abbreviated, time: .omitted))
         } else {
            return Text(.workoutDateMissing)
        }
    }

    var exerciseSetWorkoutName: some View {
        if let workout = exerciseSet.workout {
            return Text(workout.workoutName)
         } else {
            return Text(.workoutNameMissing)
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            exerciseSetWorkoutDate
            exerciseSetWorkoutName
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ExerciseHistoryRowView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseHistoryRowView(exerciseSet: ExerciseSet.example)
    }
}
