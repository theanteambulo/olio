//
//  EditExerciseView.swift
//  Olio
//
//  Created by Jake King on 24/11/2021.
//

import SwiftUI

/// A view to edit the details of a given exercise.
struct EditExerciseView: View {
    /// The exercise used to construct this view and be edited.
    @ObservedObject var exercise: Exercise

    /// The environment singleton responsible for managing the Core Data stack.
    @EnvironmentObject var dataController: DataController

    /// The exercise's name property value.
    @State private var name: String

    /// The exercise's category property value.
    @State private var exerciseCategory: Int

    /// The exercise's muscle group property value.
    @State private var muscleGroup: Int

    /// Boolean to indicate some change to the exercise's settings was made.
    @State private var changeMade = false

    /// Boolean to indicate whether the alert warning the user about deleting the exercise is displayed.
    @State private var showingDeleteExerciseAlert = false

    init(exercise: Exercise) {
        self.exercise = exercise

        _name = State(wrappedValue: exercise.exerciseName)
        _exerciseCategory = State(wrappedValue: Int(exercise.category))
        _muscleGroup = State(wrappedValue: Int(exercise.muscleGroup))
    }

    /// The exercise sets this exercise is parent of, filtered to only show those which are completed and not part of a
    /// template workout.
    var filteredExerciseSets: [ExerciseSet] {
        exercise.exerciseSets.filter({ $0.completed == true && $0.workout?.template == false })
    }

    /// A toolbar button used for deleting the exercise.
    var deleteExerciseToolbarItem: some ToolbarContent {
        ToolbarItem {
            Button(role: .destructive) {
                showingDeleteExerciseAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
            .alert(Strings.areYouSureAlertTitle.localized,
                   isPresented: $showingDeleteExerciseAlert) {
                Button(Strings.deleteButton.localized, role: .destructive) {
                    dataController.delete(exercise)
                }

                Button(Strings.cancelButton.localized, role: .cancel) { }
            } message: {
                Text(.deleteExerciseConfirmationMessage)
            }
        }
    }

    var body: some View {
        Form {
            Section(header: Text(.basicSettings)) {
                TextField(Strings.exerciseName.localized, text: $name.onChange(changesMade))

                Picker(Strings.exerciseCategory.localized, selection: $exerciseCategory.onChange(changesMade)) {
                    Text(.weighted).tag(1)
                    Text(.bodyweight).tag(2)
                    Text(.cardio).tag(3)
                    Text(.exerciseClass).tag(4)
                    Text(.stretch).tag(5)
                }

                Picker(Strings.muscleGroup.localized, selection: $muscleGroup.onChange(changesMade)) {
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

            Button(Strings.saveChanges.localized) {
                update()
                changeMade = false
            }
                .disabled(!changeMade)

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
                dataController.save()
            }
        }
        .toolbar {
            deleteExerciseToolbarItem
        }
    }

    /// Synchronise the @State properties of the view with their Core Data equivalents in whichever Exercise
    /// object is being edited.
    ///
    /// Changes will be announced to any property wrappers observing the exercise.
    func update() {
        exercise.objectWillChange.send()

        exercise.name = name
        exercise.category = Int16(exerciseCategory)
        exercise.muscleGroup = Int16(muscleGroup)
    }

    /// Toggles the Boolean indicating some change to the exercise's settings has been made.
    func changesMade() {
        changeMade = true
    }
}

struct EditExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        EditExerciseView(exercise: Exercise.example)
    }
}
