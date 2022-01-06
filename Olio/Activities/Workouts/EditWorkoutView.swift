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

    /// Boolean to indicate whether the date picker sheet for selecting other date options is displayed.
    @State private var showingDatePickerSheet = false

    /// Boolean to indicate whether the alert confirming the workout date has been changed is displayed.
    @State private var showingDateChangeConfirmation = false

    /// Boolean to indicate whether the alert warning the user about removing an exercise from the workout is displayed.
    @State private var showingRemoveConfirmation = false

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

    var completeScheduleWorkoutButton: LocalizedStringKey {
        return workout.completed
        ? Strings.rescheduleButton.localized
        : Strings.completeButton.localized
    }

    /// Computed property to get text displayed on the button for deleting a workout.
    ///
    /// Conditional on the completed property of the workout.
    var deleteWorkoutTemplateButtonText: LocalizedStringKey {
        workout.template
        ? Strings.deleteTemplateButton.localized
        : Strings.deleteWorkoutButton.localized
    }

    /// Computed property to get the date string of the workout formatted to omit the time component but show the date
    /// in full.
    var dateString: String {
        date.formatted(date: .complete, time: .omitted)
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
    ///
    /// Conditional on the completed property of the workout.
    var workoutDateSectionHeader: Text {
        workout.completed
        ? Text(.completedSectionHeader)
        : Text(.scheduledSectionHeader)
    }

    /// Computed property to get the text displayed in the navigation title of the view.
    ///
    /// Conditional on the template property of the workout.
    var navigationTitle: Text {
        workout.template
        ? Text(.editTemplateNavigationTitle)
        : Text(.editWorkoutNavigationTitle)
    }

    /// Computed property to get the text displayed in the alert message shown when deleting a workout.
    ///
    /// Conditional on the template property of the workout.
    var deleteWorkoutTemplateAlertMessage: Text {
        workout.template
        ? Text(.deleteTemplateConfirmationMessage)
        : Text(.deleteWorkoutConfirmationMessage)
    }

    /// Computed property to get the text displayed in the alert message shown when changing the date
    /// property of a workout.
    ///
    /// Conditional on the completed property of the workout.
    var dateChangeConfirmationAlertMessage: Text {
        if workout.completed {
            return Text(.completedWorkoutDateChangeAlertMessage)
        } else {
            return Text(.scheduledWorkoutDateChangeAlertMessage)
        }
    }

    var body: some View {
        Form {
            // Basic settings.
            Section(header: Text(.basicSettings)) {
                TextField(Strings.workoutName.localized,
                          text: $name.onChange(update))
            }

            // If the workout isn't a template, show date editing option.
            if !workout.template {
                Section(header: workoutDateSectionHeader) {
                    Button {
                        showingDateConfirmationDialog = true
                    } label: {
                        Text("\(date.formatted(date: .complete, time: .omitted))")
                    }
                    .accessibilityIdentifier("Workout Date")
                    .confirmationDialog("Select a date",
                                        isPresented: $showingDateConfirmationDialog) {
                        Button("Today") {
                            withAnimation {
                                saveNewWorkoutDate(dayOffset: 0)
                            }
                        }

                        Button("Tomorrow") {
                            withAnimation {
                                saveNewWorkoutDate(dayOffset: 1)
                            }
                        }

                        ForEach(2...7, id: \.self) { dayOffset in
                            Button("\(getDateOption(dayOffset).formatted(date: .complete, time: .omitted))") {
                                withAnimation {
                                    saveNewWorkoutDate(dayOffset: Double(dayOffset))
                                }
                            }
                        }
                    } message: {
                        Text("Select a date to schedule this workout on or view more date options.")
                    }
                }
                .accessibilityIdentifier("Workout Date")
            }

            Section(header: Text("Exercises")) {
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

            Section(header: Text("")) {
                if !workout.template {
                    // Button to create a template from the workout.
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
                } else {
                    // Button to create a workout from the template.
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

                // Button to delete the workout.
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
        }
        .navigationTitle(navigationTitle)
        .onDisappear(perform: dataController.save)
        .toolbar {
            completeScheduleWorkoutToolbarItem
        }
    }

    func getDateOption(_ dayOffset: Int) -> Date {
        let dateOption = Date.now + Double(dayOffset * 86400)
        return dateOption
    }

    func saveNewWorkoutDate(dayOffset: Double) {
        date = Date.now + (dayOffset * 86400)
        update()
        dataController.save()
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

    /// Create a workout or template from a given workout.
    ///
    /// Note the workout can be a template or a "normal" workout, i.e. not a template.
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
