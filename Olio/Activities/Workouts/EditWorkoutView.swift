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

    /// The workout's date property value.
    @State private var date: Date

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
        _date = State(wrappedValue: workout.workoutDate)
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

    // Navigation bar

    /// Computed property to get the text displayed in the navigation title of the view.
    var navigationTitle: Text {
        workout.template
        ? Text(.editTemplateNavigationTitle)
        : Text(.editWorkoutNavigationTitle)
    }

    /// Button copy used in alert presented after a user completes or reschedules a workout.
    var completeScheduleWorkoutButton: LocalizedStringKey {
        return workout.completed
        ? Strings.rescheduleButton.localized
        : Strings.completeButton.localized
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

    // Workout date

    /// Computed property to get the text displayed in the section header for the workout date.
    var workoutDateSectionHeader: Text {
        workout.completed
        ? Text(.completedSectionHeader)
        : Text(.scheduledSectionHeader)
    }

    /// Computed property to get the date string of the workout formatted to omit the time component but show the date
    /// in full.
    var dateString: String {
        date.formatted(date: .complete, time: .omitted)
    }

    /// Button that presents a confirmation dialog enabling the user to schedule a workout for up to 7 days in advance.
    var workoutDateButton: some View {
        Button {
            showingDateConfirmationDialog = true
        } label: {
            Text(dateString)
        }
        .accessibilityIdentifier("Workout date")
        .confirmationDialog(Strings.selectWorkoutDateLabel.localized,
                            isPresented: $showingDateConfirmationDialog) {
            Button(Strings.today.localized) {
                saveNewWorkoutDate(dayOffset: 0)
            }

            Button(Strings.tomorrow.localized) {
                saveNewWorkoutDate(dayOffset: 1)
            }

            ForEach(2...7, id: \.self) { dayOffset in
                Button("\(getDateOption(dayOffset).formatted(date: .complete, time: .omitted))") {
                    saveNewWorkoutDate(dayOffset: Double(dayOffset))
                }
            }
        } message: {
            Text(.selectWorkoutDateMessage)
        }
    }

    // Exercise list

    /// The list of exercises contained in the workout, as well as a button to add additional exercises.
    var workoutExerciseList: some View {
        List {
            // List of exercises the workout is parent of.
            ForEach(sortedExercises, id: \.self) { exercise in
                EditWorkoutExerciseListView(workout: workout,
                                            exercise: exercise)
            }
            .onDelete { offsets in
                let allExercises = sortedExercises

                for offset in offsets {
                    let exerciseToDelete = allExercises[offset]
                    dataController.removeExerciseFromWorkout(exerciseToDelete, workout)
                    dataController.save()
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

    // Create workout/template from template/workout

    /// Button enabling the user to create a template from a workout.
    var createTemplateFromWorkoutButton: some View {
        Button(Strings.createTemplateFromWorkoutButton.localized) {
            showingCreateTemplateConfirmation.toggle()
        }
        .alert(Strings.createTemplateConfirmationTitle.localized,
               isPresented: $showingCreateTemplateConfirmation) {
            Button(Strings.confirmButton.localized) {
                createWorkoutFromExisting(workout,
                                          newWorkoutIsTemplate: true)
            }

            Button(Strings.cancelButton.localized, role: .cancel) { }
        } message: {
            Text(.createTemplateConfirmationMessage)
        }
    }

    /// Button enabling the user to create a workout from a template.
    var createWorkoutFromTemplateButton: some View {
        Button(Strings.createWorkoutFromTemplateButton.localized) {
             showingCreateWorkoutConfirmation.toggle()
        }
        .alert(Strings.createWorkoutConfirmationTitle.localized,
               isPresented: $showingCreateWorkoutConfirmation) {
            Button(Strings.confirmButton.localized) {
                createWorkoutFromExisting(workout,
                                          newWorkoutIsTemplate: false)
            }

            Button(Strings.cancelButton.localized, role: .cancel) { }
        } message: {
            Text(.createWorkoutConfirmationMessage)
        }
    }

    // Delete workout

    /// Button to delete the workout.
    var deleteWorkoutButton: some View {
        Button(deleteWorkoutTemplateButtonText, role: .destructive) {
            showingDeleteWorkoutConfirmation.toggle()
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
        workout.template
        ? Strings.deleteTemplateButton.localized
        : Strings.deleteWorkoutButton.localized
    }

    /// Computed property to get the text displayed in the alert message shown when deleting a workout.
    var deleteWorkoutTemplateAlertMessage: Text {
        workout.template
        ? Text(.deleteTemplateConfirmationMessage)
        : Text(.deleteWorkoutConfirmationMessage)
    }

    var body: some View {
        Form {
            Section(header: Text(.basicSettings)) {
                TextField(Strings.workoutName.localized,
                          text: $name)
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

    /// Returns a date offset by a given number of days from today.
    /// - Parameter dayOffset: The number of days offset from the current date the workout option will be.
    /// - Returns: A date offset by a given number of days from today.
    func getDateOption(_ dayOffset: Int) -> Date {
        let dateOption = Date.now + Double(dayOffset * 86400)
        return dateOption
    }

    /// Saves the new workout date the user selected.
    /// - Parameter dayOffset: The number of days offset from the current date the workout is scheduled on.
    func saveNewWorkoutDate(dayOffset: Double) {
        date = Date.now + (dayOffset * 86400)
    }

    /// Synchronise the @State properties of the view with their Core Data equivalents in whichever Workout
    /// object is being edited.
    ///
    /// Changes will be announced to any property wrappers observing the workout.
    func update() {
        workout.objectWillChange.send()

        workout.name = name
        workout.date = date
    }

    /// Create a workout or template from a given workout or template.
    /// - Parameters:
    ///   - workout: The workout to use as the basis for creating a new workout.
    ///   - newWorkoutIsTemplate: Boolean to indicate whether the workout being created is a template or not.
    func createWorkoutFromExisting(_ workout: Workout, newWorkoutIsTemplate: Bool) {
        let newWorkout = Workout(context: managedObjectContext)
        newWorkout.id = UUID()
        newWorkout.name = workout.workoutName
        newWorkout.date = Date()
        newWorkout.completed = false

        if newWorkoutIsTemplate {
            newWorkout.template = true
        } else {
            newWorkout.template = false
        }

        var newWorkoutSets = [ExerciseSet]()

        for exerciseSet in workout.workoutExerciseSets.sorted(by: \ExerciseSet.exerciseSetCreationDate) {
            let exerciseSetToAdd = ExerciseSet(context: managedObjectContext)
            exerciseSetToAdd.id = UUID()
            exerciseSetToAdd.workout = newWorkout
            exerciseSetToAdd.exercise = exerciseSet.exercise
            exerciseSetToAdd.weight = Double(exerciseSet.exerciseSetWeight)
            exerciseSetToAdd.reps = Int16(exerciseSet.exerciseSetReps)
            exerciseSetToAdd.distance = Double(exerciseSet.exerciseSetDistance)
            exerciseSetToAdd.duration = Int16(exerciseSet.exerciseSetDuration)
            exerciseSetToAdd.creationDate = Date()
            exerciseSetToAdd.completed = false

            newWorkoutSets.append(exerciseSetToAdd)
        }

        newWorkout.exercises = NSSet(array: workout.workoutExercises)
        newWorkout.sets = NSSet(array: newWorkoutSets)

        dataController.save()
    }
}

struct EditWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        EditWorkoutView(workout: Workout.example)
    }
}
