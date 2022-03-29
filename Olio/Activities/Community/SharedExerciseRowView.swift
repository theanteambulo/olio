//
//  SharedExerciseRowView.swift
//  Olio
//
//  Created by Jake King on 29/03/2022.
//

import SwiftUI

struct SharedExerciseRowView: View {
    var sharedExercise: SharedExercise

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(sharedExercise.name)")
                    .font(.headline)

                Text("\(sharedExercise.category) | \(sharedExercise.muscleGroup)")
                    .font(.caption)
                    .foregroundColor(
                        Exercise.allExerciseCategoryColors[sharedExercise.category] ?? .secondary
                    )
                    .padding(.bottom, 2)
            }

            Spacer()

            VStack(alignment: .leading) {
                HStack {
                    Spacer()

                    combinedSetRepsInformation(forExercise: sharedExercise)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Spacer()

                    Text(.targetWeight)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 3)

                    getBodyweightExerciseWeightString(forExercise: sharedExercise)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 5)
    }

    func getBodyweightExerciseWeightString(forExercise exercise: SharedExercise) -> Text {
        if exercise.category == "Bodyweight" {
            return Text(.notApplicable)
        } else {
            return Text("\(exercise.targetWeight, specifier: "%.2f")kg")
        }
    }

    func targetRepRange(forExercise exercise: SharedExercise) -> Text {
        let upperBound = exercise.targetReps + 2
        let lowerBound = exercise.targetReps - 2 >= 1 ? exercise.targetReps - 2 : 1

        return Text("\(lowerBound)-\(upperBound) reps")
    }

    func combinedSetRepsInformation(forExercise exercise: SharedExercise) -> Text {
        return Text("\(exercise.setCount) sets") + Text(" | ") + targetRepRange(forExercise: exercise)
    }
}

struct SharedExerciseRowView_Previews: PreviewProvider {
    static var previews: some View {
        SharedExerciseRowView(sharedExercise: SharedExercise.example)
    }
}
