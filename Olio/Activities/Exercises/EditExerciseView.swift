//
//  EditExerciseView.swift
//  Olio
//
//  Created by Jake King on 24/11/2021.
//

import SwiftUI

struct EditExerciseView: View {
    @ObservedObject var exercise: Exercise

    @EnvironmentObject var dataController: DataController

    @State private var name: String
    @State private var muscleGroup: Int

    init(exercise: Exercise) {
        self.exercise = exercise

        _name = State(wrappedValue: exercise.exerciseName)
        _muscleGroup = State(wrappedValue: Int(exercise.muscleGroup))
    }

    var filteredExerciseSets: [ExerciseSet] {
        exercise.exerciseSets.filter({ $0.completed == true })
    }

    var body: some View {
        Form {
            Section(header: Text("Basic Settings")) {
                TextField("Exercise name", text: $name)

                Picker("Muscle Group", selection: $muscleGroup) {
                    Text("Chest").tag(1)
                    Text("Back").tag(2)
                    Text("Shoulders").tag(3)
                    Text("Biceps").tag(4)
                    Text("Triceps").tag(5)
                    Text("Legs").tag(6)
                    Text("Abs").tag(7)
                }
            }

            if filteredExerciseSets.isEmpty {
                EmptyView()
            } else {
                Section(header: Text("Exercise History")) {
                    List {
                        ForEach(filteredExerciseSets) { exerciseSet in
                            HStack {
                                VStack(alignment: .leading) {
                                    // swiftlint:disable:next line_length
                                    Text(exerciseSet.workout?.workoutDate.formatted(date: .abbreviated, time: .omitted) ?? "Workout date missing")
                                    Text(exerciseSet.workout?.workoutName ?? "Workout name missing")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Text("\(exerciseSet.reps) \(exerciseSet.reps == 1 ? "rep" : "reps")")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Edit Exercise")
        .onDisappear {
            withAnimation {
                update()
                dataController.save()
            }
        }
    }

    func update() {
        exercise.objectWillChange.send()

        exercise.name = name
        exercise.muscleGroup = Int16(muscleGroup)
    }
}

struct EditExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        EditExerciseView(exercise: Exercise.example)
    }
}
