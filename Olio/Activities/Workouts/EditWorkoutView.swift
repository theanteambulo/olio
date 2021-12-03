//
//  EditWorkoutView.swift
//  Olio
//
//  Created by Jake King on 24/11/2021.
//

import SwiftUI

struct EditWorkoutView: View {
    @ObservedObject var workout: Workout

    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var managedObjectContext

    @State private var name: String
    @State private var date: Date

    @State private var showingAddExerciseSheet = false
    @State private var showingDateChangeConfirmation = false
    @State private var showingRemoveConfirmation = false
    @State private var showingCompleteConfirmation = false
    @State private var showingCreateTemplateConfirmation = false
    @State private var showingCreateWorkoutConfirmation = false
    @State private var showingDeleteWorkoutConfirmation = false

    init(workout: Workout) {
        self.workout = workout

        _name = State(wrappedValue: workout.workoutName)
        _date = State(wrappedValue: workout.workoutDate)
    }

    var sortedExercises: [Exercise] {
        return workout.workoutExercises.sorted { first, second in
            if first.exerciseName < second.exerciseName {
                return true
            } else {
                return false
            }
        }
    }

    var addExerciseToWorkoutToolbarItem: some ToolbarContent {
        ToolbarItem {
            Button {
                showingAddExerciseSheet = true
            } label: {
                Label("Add", systemImage: "plus")
            }
            .sheet(isPresented: $showingAddExerciseSheet) {
                AddExerciseToWorkoutView(workout: workout)
            }
        }
    }

    var workoutDateSectionHeader: LocalizedStringKey {
        workout.completed
        ? Strings.completedSectionHeader.localized
        : Strings.scheduledSectionHeader.localized
    }

    var completeScheduleWorkoutButtonText: LocalizedStringKey {
        workout.completed
        ? Strings.scheduleWorkout.localized
        : Strings.completeWorkout.localized
    }

    var deleteWorkoutTemplateButtonText: LocalizedStringKey {
        workout.template
        ? Strings.deleteTemplateButton.localized
        : Strings.deleteWorkoutButton.localized
    }

    var deleteWorkoutTemplateAlertMessage: some View {
        workout.template
        ? Text(.deleteTemplateConfirmationMessage)
        : Text(.deleteWorkoutConfirmationMessage)
    }

    var navigationTitle: LocalizedStringKey {
        workout.template
        ? Strings.editTemplateNavigationTitle.localized
        : Strings.editWorkoutNavigationTitle.localized
    }

    var dateString: String {
        date.formatted(date: .complete, time: .omitted)
    }

    var dateChangeConfirmation: some View {
        if workout.completed {
            return Text(.completedWorkoutDateChangeAlertMessage)
        } else {
            return Text(.scheduledWorkoutDateChangeAlertMessage)
        }
    }

    var body: some View {
        Form {
            Section(header: Text(.basicSettings)) {
                TextField(Strings.workoutName.localized,
                          text: $name.onChange(update))
            }

            if !workout.template {
                Section(header: Text(workoutDateSectionHeader)) {
                    NavigationLink(
                        destination: {
                            DatePicker(
                                Strings.workoutDate.localized,
                                selection: $date.onChange {
                                    showingDateChangeConfirmation.toggle()
                                },
                                displayedComponents: .date
                            )
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .alert(dateString, isPresented: $showingDateChangeConfirmation) {
                                Button(Strings.okButton.localized, role: .cancel) {
                                    update()
                                    dataController.save()
                                }
                            } message: {
                                dateChangeConfirmation
                            }
                        }, label: {
                            Text("\(date.formatted(date: .complete, time: .omitted))")
                        }
                    )
                }
            }

            List {
                ForEach(sortedExercises, id: \.self) { exercise in
                    EditWorkoutExerciseListView(workout: workout,
                                                exercise: exercise)
                }
            }

            Section(header: Text("")) {
                if !workout.template {
                    Button(completeScheduleWorkoutButtonText) {
                        showingCompleteConfirmation.toggle()
                    }
                    .alert(workout.getConfirmationAlertTitle(workout: workout),
                           isPresented: $showingCompleteConfirmation) {
                        Button(Strings.okButton.localized, role: .cancel) {
                            workout.completed.toggle()
                        }
                    } message: {
                        Text(workout.getConfirmationAlertMessage(workout: workout))
                    }

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
            addExerciseToWorkoutToolbarItem
        }
    }

    func update() {
        workout.objectWillChange.send()

        workout.name = name
        workout.date = date
    }

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
            exerciseSetToAdd.reps = Int16(exerciseSet.exerciseSetReps)
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
