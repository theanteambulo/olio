//
//  EditWorkoutView.swift
//  Olio
//
//  Created by Jake King on 24/11/2021.
//

import CoreHaptics
import SwiftUI

/// A view to edit the details of a given workout, including templates.
// swiftlint:disable:next type_body_length
struct EditWorkoutView: View {
    /// The Workout object used to construct this view.
    @ObservedObject var workout: Workout
    /// The array of Exercise objects used to construct this view.
    @State private var exercises = [Exercise]()

    /// The environment singleton responsible for managing the Core Data stack.
    @EnvironmentObject var dataController: DataController

    /// The object space in which all managed objects exist.
    @Environment(\.managedObjectContext) var managedObjectContext
    /// Allows for the view to be dismissed programmatically.
    @Environment(\.dismiss) var dismiss

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

    /// The instance of CHHapticEngine responsible for spinning up the Taptic Engine.
    @State private var engine = try? CHHapticEngine()

    init(workout: Workout) {
        self.workout = workout

        _name = State(wrappedValue: workout.workoutName)
    }

    /// Computed property to get the text displayed in the navigation title of the view.
    var navigationTitle: Text {
        workout.template ? Text(.editTemplateNavigationTitle) : Text(.editWorkoutNavigationTitle)
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

    /// Boolean value indicating whether a full swipe is permitted for the exercise row view.
    var allowsFullSwipe: Bool {
        return (workout.template || workout.workoutExerciseSets.filter({ !$0.completed }).isEmpty) ? true : false
    }

    /// The list of exercises contained in the workout, as well as a button to add additional exercises.
    var workoutExerciseList: some View {
        List {
            // List of exercises the workout is parent of.
            ForEach(exercises, id: \.self) { exercise in
                EditWorkoutExerciseListView(workout: workout,
                                            exercise: exercise)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            withAnimation {
                                dataController.removeExercise(exercise, fromWorkout: workout)
                                exercises.removeAll(where: { $0.exerciseId == exercise.exerciseId })
                                save()
                            }
                        } label: {
                            Label(Strings.deleteButton.localized, systemImage: "trash")
                                .labelStyle(.titleAndIcon)
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: allowsFullSwipe) {
                        Button {
                            dataController.addSet(toExercise: exercise, inWorkout: workout)
                            update()
                            save()
                        } label: {
                            Label(Strings.addSet.localized, systemImage: "plus.circle")
                                .labelStyle(.titleAndIcon)
                        }
                        .tint(.blue)

                        if !allowsFullSwipe {
                            Button {
                                withAnimation {
                                    dataController.completeNextSet(forExercise: exercise, inWorkout: workout)
                                    update()
                                    save()
                                }
                            } label: {
                                Label(Strings.completeNextSetButton.localized, systemImage: "checkmark.circle")
                                    .labelStyle(.titleAndIcon)
                            }
                            .tint(.green)
                        }
                    }
            }
            .onDelete(perform: removeExerciseFromWorkout)
            .onMove(perform: reorderExercises)

            // Button to add a new exercise to the workout.
            Button {
                withAnimation {
                    showingAddExerciseSheet = true
                }
            } label: {
                Label(Strings.addExercise.localized, systemImage: "plus")
            }
            .sheet(isPresented: $showingAddExerciseSheet, onDismiss: setExercisesArray) {
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
        .confirmationDialog(Strings.scheduleWorkout.localized,
                            isPresented: $showingDateConfirmationDialog) {
            WorkoutDateConfirmationDialog(workout: workout)
        } message: {
            Text(.selectWorkoutDateMessage)
        }
    }

    var completeWorkoutButtonCopy: LocalizedStringKey {
        return workout.completed
        ? Strings.markWorkoutIncomplete.localized
        : Strings.completeWorkout.localized
    }

    var completeWorkoutButton: some View {
        Button(completeWorkoutButtonCopy) {
            showingCompleteConfirmation = true
        }
        .alert(workout.getConfirmationAlertTitle(workout: workout),
               isPresented: $showingCompleteConfirmation) {
            Button(Strings.confirmButton.localized, action: toggleCompletionStatus)

            Button(Strings.cancelButton.localized, role: .cancel, action: { })
        } message: {
            Text(workout.getConfirmationAlertMessage(workout: workout))
        }
    }

    /// Button to delete the workout.
    var deleteWorkoutButton: some View {
        Button(deleteWorkoutTemplateButtonText, role: .destructive) {
            showingDeleteWorkoutConfirmation = true

            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
        .alert(Strings.areYouSureAlertTitle.localized,
               isPresented: $showingDeleteWorkoutConfirmation) {
            Button(Strings.deleteButton.localized, role: .destructive) {
                dataController.delete(workout)
                dismiss()
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
            Section(header: Text(.workoutName)) {
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

            if !workout.template {
                Section {
                    createTemplateFromWorkoutButton
                }
                .sectionButton()
                .background(Color.blue)

                Section {
                    completeWorkoutButton
                }
                .sectionButton()
                .background(workout.completed ? Color.orange : Color.green)
            } else {
                Section {
                    createWorkoutFromTemplateButton
                }
                .sectionButton()
                .background(Color.blue)
            }

            Section {
                deleteWorkoutButton
            }
            .sectionButton()
            .background(Color.red)
        }
        .navigationTitle(navigationTitle)
        .toolbar {
            EditButton()
        }
        .onAppear(perform: setExercisesArray)
        .onDisappear {
            update()
            save()
        }
    }

    /// Sets the exercises array used to construct this view.
    func setExercisesArray() {
        exercises = workout.workoutExercises.sorted { first, second in
            let firstIndex = dataController.getPlacement(forExercise: first, inWorkout: workout)
            let secondIndex = dataController.getPlacement(forExercise: second, inWorkout: workout)

            if  firstIndex ?? 0 < secondIndex ?? 0 {
                return true
            } else {
                return false
            }
        }
    }

    /// Enables users to drag rows in the list of exercises to reorder them.
    /// - Parameters:
    ///   - source: The original placement of the row being moved in the exercises array.
    ///   - destination: The new placement of the row being moved in the exercises array.
    func reorderExercises(from source: IndexSet, to destination: Int) {
        exercises.move(fromOffsets: source, toOffset: destination)
        dataController.updateOrderOfExercises(toMatch: exercises, forWorkout: workout)
    }

    /// Responsible for toggling the completion status of the workout and generating haptic feedback.
    func toggleCompletionStatus() {
        workout.completed.toggle()
        save()

        if workout.completed {
            do {
                try engine?.start()

                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)

                let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
                let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 0)

                let parameterCurve = CHHapticParameterCurve(
                    parameterID: .hapticIntensityControl,
                    controlPoints: [start, end],
                    relativeTime: 0
                )

                let transientEvent = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: 0
                )

                let continuousEvent = CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [intensity, sharpness],
                    relativeTime: 0.125,
                    duration: 1
                )

                let pattern = try CHHapticPattern(
                    events: [transientEvent, continuousEvent],
                    parameterCurves: [parameterCurve])

                let player = try engine?.makePlayer(with: pattern)
                try player?.start(atTime: 0)
            } catch {
                // Playing haptics didn't work, but that's ok.
            }
        }
    }

    /// Removes an exercise from a workout using its position in the list displayed to the user.
    ///
    /// Should only be used within this view in the onDelete modifier for the workout list. The swipe action delete
    /// button uses a DataController method to remove the exercise from the workout.
    /// - Parameters:
    ///   - offsets: The position of the exercise in the list displayed to the user.
    ///   - workout: The workout from which the exercise should be deleted.
    func removeExerciseFromWorkout(at offsets: IndexSet) {
        exercises.remove(atOffsets: offsets)

        if let offset = offsets.first {
            let exerciseToRemove = exercises[offset]
            dataController.removeExercise(exerciseToRemove, fromWorkout: workout)
            save()
        }
    }

    /// Synchronise the @State properties of the view with their Core Data equivalents in whichever Workout
    /// object is being edited.
    ///
    /// Changes will be announced to any property wrappers observing the workout.
    func update() {
        workout.objectWillChange.send()

        workout.name = name
        workout.setValue(NSSet(array: exercises), forKey: "exercises")
    }

    func save() {
        dataController.updateWorkout(workout)
    }
}

struct EditWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        EditWorkoutView(workout: Workout.example)
    }
// swiftlint:disable:next file_length
}
