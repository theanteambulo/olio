//
//  EditWorkoutView.swift
//  Olio
//
//  Created by Jake King on 24/11/2021.
//

import SwiftUI

struct EditWorkoutView: View {
    let workout: Workout

    @EnvironmentObject var dataController: DataController
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss

    @State private var name: String
    @State private var dateScheduled: Date
    @State private var dateCompleted: Date
    @State private var showingDeleteConfirmation = false

    init(workout: Workout) {
        self.workout = workout

        _name = State(wrappedValue: workout.workoutName)
        _dateScheduled = State(wrappedValue: workout.workoutDateScheduled)
        _dateCompleted = State(wrappedValue: workout.workoutDateCompleted)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Settings")) {
                    TextField("Workout name",
                              text: $name.onChange(update))

                    DatePicker("Date scheduled",
                               selection: $dateScheduled.onChange(update),
                               displayedComponents: .date)

                    DatePicker("Date completed",
                               selection: $dateCompleted.onChange(update),
                               displayedComponents: .date)
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
                }

                Section(header: Text("Complete a workout when you've finished every set for all exercises.")) {
                    Button(workout.completed ? "Mark workout incomplete" : "Complete workout") {
                        workout.completed.toggle()
                        update()
                    }
                }

                Section(header: Text("Deleting a workout cannot be undone.")) {
                    Button("Delete workout") {
                        showingDeleteConfirmation.toggle()
                    }
                    .tint(.red)
                }
            }
            .navigationTitle("Edit Workout")
            .navigationBarItems(trailing: Button("Save") {
                dismiss()
            })
        }
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
        workout.name = name
        workout.dateScheduled = dateScheduled
        workout.dateCompleted = dateCompleted
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
