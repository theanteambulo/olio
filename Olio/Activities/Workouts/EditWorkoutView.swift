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

    @State private var name: String
    @State private var date: Date

    @State private var showingDeleteWorkoutConfirmation = false
    @State private var showingAddExerciseSheet = false
    @State private var showingCompleteConfirmation = false

    @State private var showingRemoveConfirmation = false

    @State private var completeConfirmationTitle = ""
    @State private var completeConfirmationMessage = ""

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

    var body: some View {
        Form {
            Section(header: Text("Basic Settings")) {
                TextField("Workout name",
                          text: $name.onChange(update))

                DatePicker("Date",
                           selection: $date.onChange(update),
                           displayedComponents: .date)
            }

            Button("Add Exercise") {
                showingAddExerciseSheet = true
            }
            .sheet(isPresented: $showingAddExerciseSheet) {
                AddExerciseToWorkoutView(workout: workout)
            }

            List {
                ForEach(sortedExercises, id: \.self) { exercise in
                    EditWorkoutExerciseListView(workout: workout,
                                                exercise: exercise)
                }
            }

            Section(header: Text("")) {
                Button(workout.completed ? "Schedule workout" : "Complete workout") {
                    workout.completed.toggle()
                }
                .alert(workout.getConfirmationAlertTitle(workout: workout),
                       isPresented: $showingCompleteConfirmation) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(workout.getConfirmationAlertMessage(workout: workout))
                }

                Button("Delete workout", role: .destructive) {
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
        .navigationTitle("Edit Workout")
        .onDisappear(perform: dataController.save)
    }

    func update() {
        workout.objectWillChange.send()

        workout.name = name
        workout.date = date
    }
}

struct EditWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        EditWorkoutView(workout: Workout.example)
    }
}
