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
    @State private var showingDeleteExerciseConfirmation = false
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
                    Section(header: Text("\(exercise.exerciseName)")) {
                        ExerciseHeaderView(workout: workout,
                                           exercise: exercise)

                        ForEach(filterExerciseSets(exercise.exerciseSets), id: \.self) { exerciseSet in
                            ExerciseSetView(exerciseSet: exerciseSet)
                        }
                        .onDelete { offsets in
                            let allExerciseSets = filterExerciseSets(exercise.exerciseSets)

                            for offset in offsets {
                                let exerciseSetToDelete = allExerciseSets[offset]

                                withAnimation {
                                    deleteExerciseSet(exerciseSet: exerciseSetToDelete)
                                }
                            }
                        }

                        Button("Add Set") {
                            withAnimation {
                                addSet(toExercise: exercise, toWorkout: workout)
                                print("A set was added to the exercise.")
                            }
                        }

                        Button("Remove Exercise", role: .destructive) {
                            showingDeleteExerciseConfirmation.toggle()
                        }
                        .tint(.red)
                        .alert("Are you sure?",
                               isPresented: $showingDeleteExerciseConfirmation) {
                            Button("Remove", role: .destructive) {
                                removeExercise(exercise: exercise)
                            }

                            Button("Cancel", role: .cancel) { }
                        } message: {
                            // swiftlint:disable:next line_length
                            Text("Removing an exercise from the workout also deletes all of its sets and cannot be undone.")
                        }
                    }
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

    func filterExerciseSets(_ exerciseSets: [ExerciseSet]) -> [ExerciseSet] {
        exerciseSets.filter { $0.workout == workout }.sorted(by: \ExerciseSet.exerciseSetCreationDate)
    }

    func deleteExerciseSet(exerciseSet: ExerciseSet) {
        dataController.delete(exerciseSet)
        dataController.save()
    }

    func addSet(toExercise exercise: Exercise,
                toWorkout workout: Workout) {
        let set = ExerciseSet(context: dataController.container.viewContext)
        set.id = UUID()
        set.workout = workout
        set.exercise = exercise
        set.reps = 10
        set.creationDate = Date()
        dataController.save()
    }

    func removeExercise(exercise: Exercise) {
        var existingExercises = workout.workoutExercises
        existingExercises.removeAll { $0.id == exercise.id }

        workout.setValue(NSSet(array: existingExercises), forKey: "exercises")

        for exerciseSet in exercise.exerciseSets {
            dataController.delete(exerciseSet)
        }

        dataController.save()
    }
}

struct EditWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        EditWorkoutView(workout: Workout.example)
    }
}
