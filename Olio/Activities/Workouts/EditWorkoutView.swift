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

    var body: some View {
        Form {
            Section(header: Text("Basic Settings")) {
                TextField("Workout name",
                          text: $name.onChange(update))
            }

            if !workout.template {
                Section(header: Text("\(workout.completed ? "Completed" : "Scheduled")")) {
                    NavigationLink(
                        destination: {
                            DatePicker(
                                "Date",
                                selection: $date.onChange {
                                    showingDateChangeConfirmation.toggle()
                                },
                                displayedComponents: .date
                            )
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .alert("Workout date changed", isPresented: $showingDateChangeConfirmation) {
                                Button("OK", role: .cancel) {
                                    update()
                                }
                            } message: {
                                // swiftlint:disable:next line_length
                                Text("Your workout date has changed. You can find it on the \(workout.completed ? "History" : "Scheduled") tab, under \(date.formatted(date: .complete, time: .omitted)).")
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
                    Button(workout.completed ? "Schedule workout" : "Complete workout") {
                        showingCompleteConfirmation.toggle()
                    }
                    .alert(workout.getConfirmationAlertTitle(workout: workout),
                           isPresented: $showingCompleteConfirmation) {
                        Button("OK", role: .cancel) {
                            workout.completed.toggle()
                        }
                    } message: {
                        Text(workout.getConfirmationAlertMessage(workout: workout))
                    }

                    Button("Create template from workout") {
                        showingCreateTemplateConfirmation.toggle()
                    }
                    .alert("Create a template?",
                           isPresented: $showingCreateTemplateConfirmation) {
                        Button("Confirm") {
                            createWorkoutFromExisting(workout,
                                                      newWorkoutIsTemplate: true)
                        }

                        Button("Cancel", role: .cancel) { }
                    } message: {
                        // swiftlint:disable:next line_length
                        Text("We'll use the exercises and sets in this workout to create a new template. You can view your workout templates on the Home tab.")
                    }
                } else {
                    Button("Create workout from template") {
                         showingCreateWorkoutConfirmation.toggle()
                    }
                    .alert("Create a workout?",
                           isPresented: $showingCreateWorkoutConfirmation) {
                        Button("Confirm") {
                            createWorkoutFromExisting(workout,
                                                      newWorkoutIsTemplate: false)
                        }

                        Button("Cancel", role: .cancel) { }
                    } message: {
                        // swiftlint:disable:next line_length
                        Text("We'll use the exercises and sets in this template to create a new workout. You can view your workouts on the Home tab.")
                    }
                }

                Button(workout.template ? "Delete template" : "Delete workout", role: .destructive) {
                    showingDeleteWorkoutConfirmation.toggle()
                }
                .tint(.red)
                .alert("Are you sure?",
                       isPresented: $showingDeleteWorkoutConfirmation) {
                    Button("Delete", role: .destructive) {
                        dataController.delete(workout)
                    }

                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Deleting a workout cannot be undone and will also delete all sets contained in the workout.")
                }
            }
        }
        .navigationTitle(workout.template ? "Edit Template" : "Edit Workout")
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
