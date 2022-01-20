//
//  WorkoutRowView.swift
//  Olio
//
//  Created by Jake King on 25/11/2021.
//

import SwiftUI

/// A single row in a list of workouts representing a given workout.
struct WorkoutRowView: View {
    /// The workout used to construct this view.
    @ObservedObject var workout: Workout

    /// The array of colors corresponding to unique exercise categories in this workout.
    private var exerciseCategoryColors: [Color] = [.red, .blue, .green, .yellow, .purple]

    /// An array of Boolean values indicating whether a circle should be filled or not.
    private var fillCircle: [Bool]

    /// A grid with a single row.
    var rows: [GridItem] {
        Array(repeating: GridItem(), count: 1)
    }

    init(workout: Workout) {
        self.workout = workout
        let workoutExerciseCategoryColors = workout.workoutExercises.map({ $0.getExerciseCategoryColor() })
        fillCircle = exerciseCategoryColors.map({ workoutExerciseCategoryColors.contains($0) })
    }

    var upcomingWorkoutLabel: some View {
        let workoutDate = Calendar.current.startOfDay(for: workout.workoutDate)
        let today = Calendar.current.startOfDay(for: .now)
        let tomorrow = Calendar.current.startOfDay(for: .now.addingTimeInterval(86400))

        return Group {
            if workoutDate == today {
                Text(.today)
                    .foregroundColor(.green)
            } else if workoutDate == tomorrow {
                Text(.tomorrow)
                    .foregroundColor(.orange)
            } else {
                Text("")
            }
        }
        .font(.body.bold())
        .textCase(.uppercase)
    }

    var body: some View {
        NavigationLink(destination: EditWorkoutView(workout: workout)) {
            VStack(alignment: .leading, spacing: 0) {
                Text(workout.workoutName)
                    .font(.headline)

                LazyHGrid(rows: rows, spacing: 7) {
                    ForEach(Array(zip(exerciseCategoryColors.indices,
                                      exerciseCategoryColors)), id: \.1) { index, categoryColor in
                        Circle()
                            .strokeBorder(categoryColor, lineWidth: 1)
                            .background(Circle().fill(fillCircle[index] ? categoryColor : .clear))
                            .frame(width: 7)
                    }
                }

                HStack {
                    VStack(alignment: .leading) {
                        Text("\(workout.workoutExercises.count) exercises")
                            .font(.caption)

                        Text("\(workout.workoutExerciseSets.count) sets")
                            .font(.caption)
                    }

                    Spacer()

                    upcomingWorkoutLabel
                }
            }
            .padding(.vertical, 5)
        }
        .accessibilityIdentifier(workout.workoutName)
    }
}

struct WorkoutRowView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutRowView(workout: Workout.example)
    }
}
