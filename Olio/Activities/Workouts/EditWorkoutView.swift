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
    @Environment(\.presentationMode) var presentationMode

    @State private var name: String
    @State private var dateScheduled: Date
    @State private var dateCompleted: Date
    @State private var completed: Bool
    @State private var showingDeleteConfirmation = false
    @State private var showingAddExerciseSheet = false

    init(workout: Workout) {
        self.workout = workout

        _name = State(wrappedValue: workout.workoutName)
        _dateScheduled = State(wrappedValue: workout.workoutDateScheduled)
        _dateCompleted = State(wrappedValue: workout.workoutDateCompleted)
        _completed = State(wrappedValue: workout.completed)
    }

    var body: some View {
        Form {
            Section(header: Text(workout.template ? "Template Name" : "Basic Settings")) {
                TextField("Workout name",
                          text: $name.onChange(update))

                if !workout.template {
                    DatePicker("Date scheduled",
                               selection: $dateScheduled.onChange(update),
                               displayedComponents: .date)

                    DatePicker("Date completed",
                               selection: $dateCompleted.onChange(update),
                               displayedComponents: .date)
                }
            }

            List {
                ForEach(workout.workoutExercises) { exercise in
                    Section(header: Text(exercise.exerciseName)) {
                        ForEach(exercise.exerciseSets) { exerciseSet in
                            HStack {
                                Text("\(exerciseSet.exerciseSetReps) reps")

                                Spacer()

                                if exerciseSet.completed {
                                    Image(systemName: "checkmark.circle")
                                        .foregroundColor(.green)
                                } else {
                                    Image(systemName: "xmark.circle")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }

                Button("Add Exercise") {
                    showingAddExerciseSheet = true
                }
                .sheet(isPresented: $showingAddExerciseSheet) {
                    AddExerciseToWorkoutView(workout: workout)
                }
            }

            if !workout.template {
                Section(header: Text("Complete a workout when you've finished every set for all exercises.")) {
                    Toggle("Complete workout", isOn: $completed.onChange(update))
                }
            }

            Section(header: Text("Deleting a \(workout.template ? "template" : "workout") cannot be undone.")) {
                Button(workout.template ? "Delete template" : "Delete workout") {
                    showingDeleteConfirmation.toggle()
                }
                .tint(.red)
            }
        }
        .navigationTitle(workout.template ? "Edit Template" : "Edit Workout")
        .onDisappear(perform: dataController.save)
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(title: Text("Are you sure?"),
                  message: Text("Deleting a workout cannot be undone."),
                  primaryButton: .destructive(Text("Delete"),
                                              action: delete),
                  secondaryButton: .cancel()
            )
        }
    }

    func update() {
        workout.objectWillChange.send()

        workout.name = name
        workout.dateScheduled = dateScheduled
        workout.dateCompleted = dateCompleted
        workout.completed = completed
    }

    func delete() {
        dataController.delete(workout)
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        EditWorkoutView(workout: Workout.example)
    }
}
