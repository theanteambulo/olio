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
            Section(header: Text(.basicSettings)) {
                TextField(Strings.exerciseName.localized, text: $name)

                Picker(Strings.muscleGroup.localized, selection: $muscleGroup) {
                    Text(.chest).tag(1)
                    Text(.back).tag(2)
                    Text(.shoulders).tag(3)
                    Text(.biceps).tag(4)
                    Text(.triceps).tag(5)
                    Text(.legs).tag(6)
                    Text(.abs).tag(7)
                }
            }

            if filteredExerciseSets.isEmpty {
                EmptyView()
            } else {
                Section(header: Text(.exerciseHistory)) {
                    List {
                        ForEach(filteredExerciseSets) { exerciseSet in
                            ExerciseHistoryRowView(exerciseSet: exerciseSet)
                        }
                    }
                }
            }
        }
        .navigationTitle(Text(.editExerciseNavigationTitle))
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
