//
//  EditWorkoutView.swift
//  Olio
//
//  Created by Jake King on 24/11/2021.
//

import SwiftUI

/// A view to edit the details of a given workout, including templates.
struct EditWorkoutView: View {
    /// The workout used to construct this view.
    @ObservedObject var workout: Workout

    /// The environment singleton responsible for managing the Core Data stack.
    @EnvironmentObject var dataController: DataController

    /// The object space in which all managed objects exist.
    @Environment(\.managedObjectContext) var managedObjectContext

    /// The workout's name property value.
    @State private var name: String

    /// Boolean to indicate whether the sheet used for adding an exercise to the workout is displayed.
    @State private var showingAddExerciseSheet = false
    /// Boolean to indicate whether the confirmation dialog used for changing the workout date is displayed.
    @State private var showingDateConfirmationDialog = false
    /// Boolean to indicate whether the alert confirming the workout has been completed is displayed.
    @State private var showingCompleteConfirmation = false
    /// Boolean to indicate whether the alert confirming a template will be created is displayed.
    @State private var showingCreateTemplateConfirmation = false
    /// Boolean to indicate whether the alert confirming a workout will be created is displayed.
    @State private var showingCreateWorkoutConfirmation = false
    /// Boolean to indicate whether the alert warning the user about deleting an exercise is displayed.
    @State private var showingDeleteWorkoutConfirmation = false
    /// The opacity of the toolbar button used for completing and scheduling workouts.
    @State private var toolbarButtonOpacity: Double = 1

    init(workout: Workout) {
        self.workout = workout

        _name = State(wrappedValue: workout.workoutName)
    }

    /// Computed property to sort exercises by name.
    var sortedExercises: [Exercise] {
        return workout.workoutExercises.sorted { first, second in
            if first.exerciseName < second.exerciseName {
                return true
            } else {
                return false
            }
        }
    }

    /// Computed property to get the text displayed in the navigation title of the view.
    var navigationTitle: Text {
        workout.template ? Text(.editTemplateNavigationTitle) : Text(.editWorkoutNavigationTitle)
    }

    /// Button copy used in alert presented after a user completes or reschedules a workout.
    var completeScheduleWorkoutButton: LocalizedStringKey {
        return workout.completed ? Strings.rescheduleButton.localized : Strings.completeButton.localized
    }

    /// Toolbar button that displays a sheet containing AddExerciseToWorkoutView.
    var completeScheduleWorkoutToolbarItem: some ToolbarContent {
        ToolbarItem {
            if !workout.template {
                Button {
                    showingCompleteConfirmation = true
                } label: {
                    if workout.completed {
                        Label(Strings.rescheduleButton.localized, systemImage: "calendar")
                    } else {
                        Label(Strings.completeButton.localized, systemImage: "checkmark")
                    }
                }
                .opacity(toolbarButtonOpacity)
                .alert(workout.getConfirmationAlertTitle(workout: workout),
                       isPresented: $showingCompleteConfirmation) {
                    Button(completeScheduleWorkoutButton) {
                        workout.completed.toggle()
                        toolbarButtonOpacity = 0
                    }

                    Button(Strings.cancelButton.localized, role: .cancel, action: { })
                } message: {
                    Text(workout.getConfirmationAlertMessage(workout: workout))
                }
            } else {
                EmptyView()
            }
        }
    }

    /// Computed property to get the text displayed in the section header for the workout date.
    var workoutDateSectionHeader: Text {
        workout.completed ? Text(.completedSectionHeader) : Text(.scheduledSectionHeader)
    }

    /// Computed property to get the date string of the workout formatted to omit the time component but show the date
    /// in full.
    var dateString: String {
        workout.workoutDate.formatted(date: .complete, time: .omitted)
    }

    /// Button that presents a confirmation dialog enabling the user to schedule a workout for up to 7 days in advance.
    var workoutDateButton: some View {
        Button {
            showingDateConfirmationDialog = true
        } label: {
            Text(workout.workoutDate.formatted(date: .complete, time: .omitted))
        }
        .accessibilityIdentifier("Workout date")
        .confirmationDialog(Strings.selectWorkoutDateLabel.localized,
                            isPresented: $showingDateConfirmationDialog) {
            WorkoutDateConfirmationDialog(workout: workout)
        } message: {
            Text(.selectWorkoutDateMessage)
        }
    }

    /// The list of exercises contained in the workout, as well as a button to add additional exercises.
    var workoutExerciseList: some View {
        List {
            // List of exercises the workout is parent of.
            ForEach(sortedExercises, id: \.self) { exercise in
                EditWorkoutExerciseListView(workout: workout,
                                            exercise: exercise)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            withAnimation {
                                dataController.removeExercise(exercise, fromWorkout: workout)
                                dataController.save()
                            }
                        } label: {
                            Label(Strings.deleteButton.localized, systemImage: "trash")
                                .labelStyle(.titleAndIcon)
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button {
                            dataController.addSet(toExercise: exercise, inWorkout: workout)
                            update()
                            dataController.save()
                        } label: {
                            Label(Strings.addSet.localized, systemImage: "plus.circle")
                                .labelStyle(.titleAndIcon)
                        }
                        .tint(.blue)

                        Button {
                            withAnimation {
                                dataController.completeAllSets(forExercise: exercise, inWorkout: workout)
                                update()
                                dataController.save()
                            }
                        } label: {
                            Label(Strings.completeButton.localized, systemImage: "checkmark.circle")
                                .labelStyle(.titleAndIcon)
                        }
                        .tint(.green)
                    }
            }

            // Button to add a new exercise to the workout.
            Button {
                withAnimation {
                    showingAddExerciseSheet = true
                }
            } label: {
                Label(Strings.addExercise.localized, systemImage: "plus")
            }
            .sheet(isPresented: $showingAddExerciseSheet) {
                AddExerciseToWorkoutView(workout: workout)
            }
        }
    }

    /// Button enabling the user to create a template from a workout.
    var createTemplateFromWorkoutButton: some View {
        Button(Strings.createTemplateFromWorkoutButton.localized) {
            showingCreateTemplateConfirmation = true
        }
        .alert(Strings.createTemplateConfirmationTitle.localized,
               isPresented: $showingCreateTemplateConfirmation) {
            Button(Strings.confirmButton.localized) {
                dataController.createNewWorkoutOrTemplateFromExisting(workout,
                                                                      isTemplate: true)
            }

            Button(Strings.cancelButton.localized, role: .cancel) { }
        } message: {
            Text(.createTemplateConfirmationMessage)
        }
    }

    /// Button enabling the user to create a workout from a template.
    var createWorkoutFromTemplateButton: some View {
        Button(Strings.createWorkoutFromTemplateButton.localized) {
             showingCreateWorkoutConfirmation = true
        }
        .alert(Strings.createWorkoutConfirmationTitle.localized,
               isPresented: $showingCreateWorkoutConfirmation) {
            Button(Strings.confirmButton.localized) {
                showingDateConfirmationDialog = true
            }

            Button(Strings.cancelButton.localized, role: .cancel) { }
        } message: {
            Text(.createWorkoutConfirmationMessage)
        }
        .confirmationDialog("Schedule workout",
                            isPresented: $showingDateConfirmationDialog) {
            WorkoutDateConfirmationDialog(workout: workout)
        } message: {
            Text(.selectWorkoutDateMessage)
        }
    }

    /// Button to delete the workout.
    var deleteWorkoutButton: some View {
        Button(deleteWorkoutTemplateButtonText, role: .destructive) {
            showingDeleteWorkoutConfirmation = true
        }
        .tint(.red)
        .alert(Strings.areYouSureAlertTitle.localized,
               isPresented: $showingDeleteWorkoutConfirmation) {
            Button(Strings.deleteButton.localized, role: .destructive) {
                dataController.delete(workout)
            }

            Button(Strings.cancelButton.localized, role: .cancel) { }
        } message: {
            deleteWorkoutTemplateAlertMessage
        }
    }

    /// Computed property to get text displayed on the button for deleting a workout.
    var deleteWorkoutTemplateButtonText: LocalizedStringKey {
        workout.template ? Strings.deleteTemplateButton.localized : Strings.deleteWorkoutButton.localized
    }

    /// Computed property to get the text displayed in the alert message shown when deleting a workout.
    var deleteWorkoutTemplateAlertMessage: Text {
        workout.template ? Text(.deleteTemplateConfirmationMessage) : Text(.deleteWorkoutConfirmationMessage)
    }

    var body: some View {
        Form {
            Section(header: Text(.basicSettings)) {
                TextField(Strings.workoutName.localized,
                          text: $name.onChange(update))
            }

            if !workout.template {
                Section(header: workoutDateSectionHeader) {
                    workoutDateButton
                }
                .accessibilityIdentifier("Workout Date")
            }

            Section(header: Text(.exercisesTab)) {
                workoutExerciseList
            }

            Section(header: Text("")) {
                if !workout.template {
                    createTemplateFromWorkoutButton
                } else {
                    createWorkoutFromTemplateButton
                }

                deleteWorkoutButton
            }
        }
        .navigationTitle(navigationTitle)
        .onDisappear {
            update()
            dataController.save()
        }
        .toolbar {
            completeScheduleWorkoutToolbarItem
        }
    }

    /// Synchronise the @State properties of the view with their Core Data equivalents in whichever Workout
    /// object is being edited.
    ///
    /// Changes will be announced to any property wrappers observing the workout.
    func update() {
        workout.objectWillChange.send()

        workout.name = name
    }
}

struct EditWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        EditWorkoutView(workout: Workout.example)
    }
}
