//
//  AddExerciseView.swift
//  Olio
//
//  Created by Jake King on 25/11/2021.
//

import SwiftUI

/// A view to add a new exercise.
struct AddExerciseView: View {
    /// A fetch request of Exercise objects.
    let exercises: FetchRequest<Exercise>

    /// The environment singleton responsible for managing the Core Data stack.
    @EnvironmentObject var dataController: DataController

    /// The object space in which the new exercise should be created.
    @Environment(\.managedObjectContext) var managedObjectContext

    /// Provides functionality for dismissing a presentation.
    ///
    /// Used in this view for dismissing a sheet.
    @Environment(\.dismiss) var dismiss

    /// The exercise's name property value.
    @State private var name = ""

    /// The exercise's category property value.
    @State private var exerciseCategory = 1

    /// The exercise's muscle group property value.
    @State private var muscleGroup = 1

    /// Boolean to indicate whether the alert warning the user the alert already exists is displayed.
    @State private var showingExerciseAlreadyExistsAlert = false

    init() {
        exercises = FetchRequest(
            entity: Exercise.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.name,
                                               ascending: true)])
    }

    /// Computed property to get the chosen exercise name when whitespaces and fullstops are removed.
    var trimmedExerciseName: String {
        name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "."))
    }

    /// Computed property to indicate whether the chosen exercise name is valid or not.
    var exerciseNameValid: Bool {
        if trimmedExerciseName == "" {
            return false
        } else {
            if exercises.wrappedValue.filter({ $0.exerciseName == trimmedExerciseName }).isEmpty {
                return true
            } else {
                return false
            }
        }
    }

    /// A toolbar button used for saving the new exercise.
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
            .alert(Strings.errorAlertTitle.localized,
                   isPresented: $showingExerciseAlreadyExistsAlert) {
                Button(Strings.okButton.localized, role: .cancel) { }
            } message: {
                trimmedExerciseName == ""
                ? Text(.emptyNameErrorAlertMessage)
                : Text(.duplicationErrorAlertMessage)
            }
        }
    }

    /// A toolbar button used for dismissing the view without saving details of the new exercise.
    var dismissNoSaveToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                dismiss()
            } label: {
                Label("Dismiss", systemImage: "xmark")
            }
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(.basicSettings)) {
                    TextField(Strings.exerciseName.localized, text: $name)

                    Picker(Strings.exerciseCategory.localized, selection: $exerciseCategory) {
                        Text(.weights).tag(1)
                        Text(.body).tag(2)
                        Text(.cardio).tag(3)
                        Text(.exerciseClass).tag(4)
                        Text(.stretch).tag(5)
                    }

                    Picker(Strings.muscleGroup.localized, selection: $muscleGroup) {
                        Text(.chest).tag(1)
                        Text(.back).tag(2)
                        Text(.shoulders).tag(3)
                        Text(.biceps).tag(4)
                        Text(.triceps).tag(5)
                        Text(.legs).tag(6)
                        Text(.abs).tag(7)
                        Text(.fullBody).tag(8)
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

    /// Saves the new exercise to the Core Data context.
    func save() {
        let trimmedName = name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "."))

        let exercise = Exercise(context: managedObjectContext)
        exercise.id = UUID()
        exercise.name = trimmedName
        exercise.category = Int16(exerciseCategory)
        exercise.muscleGroup = Int16(muscleGroup)

        dataController.save()
    }
}

struct AddExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        AddExerciseView()
    }
}
