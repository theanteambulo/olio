//
//  EditExerciseView.swift
//  Olio
//
//  Created by Jake King on 24/11/2021.
//

import SwiftUI

struct EditExerciseView: View {
    @EnvironmentObject var dataController: DataController

    let exercise: Exercise

    @State private var name: String
    @State private var bodyweight: Bool
    @State private var muscleGroup: Int
    @State private var reps: Int
    @State private var weight: Double

    init(exercise: Exercise) {
        self.exercise = exercise

        _name = State(wrappedValue: exercise.exerciseName)
        _bodyweight = State(wrappedValue: exercise.bodyweight)
        _muscleGroup = State(wrappedValue: Int(exercise.muscleGroup))
        _reps = State(wrappedValue: Int(exercise.reps))
        _weight = State(wrappedValue: exercise.weight)
    }

    var body: some View {
        Form {
            Section(header: Text("Basic Settings")) {
                TextField("Exercise name", text: $name.onChange(update))

                Picker("Muscle Group", selection: $muscleGroup.onChange(update)) {
                    Text("Chest").tag(1)
                    Text("Back").tag(2)
                    Text("Shoulders").tag(3)
                    Text("Biceps").tag(4)
                    Text("Triceps").tag(5)
                    Text("Legs").tag(6)
                    Text("Abs").tag(7)
                }

                Toggle("Bodyweight exercise", isOn: $bodyweight.onChange(update))
            }
        }
        .navigationTitle("Edit Exercise")
        .onDisappear(perform: dataController.save)
    }

    func update() {
        exercise.objectWillChange.send()

        exercise.name = name
        exercise.muscleGroup = Int16(muscleGroup)
        exercise.bodyweight = bodyweight
    }
}

struct EditExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        EditExerciseView(exercise: Exercise.example)
    }
}
