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
            Button(Strings.saveButton.localized) {
                if exerciseNameValid {
                    save()
                    dismiss()
                } else {
                    showingExerciseAlreadyExistsAlert = true
                }
            }
            .alert(Strings.duplicationErrorAlertTitle.localized,
                   isPresented: $showingExerciseAlreadyExistsAlert) {
                Button(Strings.okButton.localized, role: .cancel) { }
            } message: {
                Text(.duplicationErrorAlertMessage)
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
            }
            .navigationTitle(Text(.addExercise))
            .toolbar {
                saveToolbarItem
                dismissNoSaveToolbarItem
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
