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

    /// The exercise's muscle group property value.
    @State private var muscleGroup: Int

    /// Boolean to indicate whether the alert warning the user about deleting the exercise is displayed.
    @State private var showingDeleteExerciseAlert = false

    init(exercise: Exercise) {
        self.exercise = exercise

        _name = State(wrappedValue: exercise.exerciseName)
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
        exercise.muscleGroup = Int16(muscleGroup)
    }
}

struct EditExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        EditExerciseView(exercise: Exercise.example)
    }
}
