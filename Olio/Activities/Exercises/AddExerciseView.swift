//
//  AddExerciseView.swift
//  Olio
//
//  Created by Jake King on 25/11/2021.
//

import SwiftUI

struct AddExerciseView: View {
    let exercises: FetchRequest<Exercise>

    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var bodyweight = true
    @State private var muscleGroup = 1
    @State private var showingExerciseAlreadyExistsAlert = false

    init() {
        exercises = FetchRequest(
            entity: Exercise.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.name,
                                               ascending: true)])
    }

    var saveToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Save") {
                if exerciseNameValid {
                    save()
                    dismiss()
                } else {
                    showingExerciseAlreadyExistsAlert = true
                }
            }
        }
    }

    var dismissNoSaveToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                dismiss()
            } label: {
                Label("Dismiss", systemImage: "xmark")
            }
        }
    }

    var exerciseNameValid: Bool {
        let trimmedName = name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "."))

        if trimmedName != "" && exercises.wrappedValue.filter({ $0.exerciseName == trimmedName }).isEmpty {
            return true
        } else {
            return false
        }
    }

    var body: some View {
        NavigationView {
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
            }
            .navigationTitle("Add Exercise")
            .toolbar {
                saveToolbarItem
                dismissNoSaveToolbarItem
            }
            .alert(isPresented: $showingExerciseAlreadyExistsAlert) {
                Alert(
                    title: Text("Oops!"),
                    message: Text("Looks like this exercise already exists. Try changing the name to proceed."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    func save() {
        let trimmedName = name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "."))

        let exercise = Exercise(context: managedObjectContext)
        exercise.id = UUID()
        exercise.name = trimmedName
        exercise.muscleGroup = Int16(muscleGroup)

        dataController.save()
    }
}

struct AddExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        AddExerciseView()
    }
}
