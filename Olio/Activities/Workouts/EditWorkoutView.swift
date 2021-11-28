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
    @State private var showingCompleteConfirmation = false

    @State private var completeConfirmationTitle = ""
    @State private var completeConfirmationMessage = ""

    init(workout: Workout) {
        self.workout = workout

        _name = State(wrappedValue: workout.workoutName)
        _dateScheduled = State(wrappedValue: workout.workoutDateScheduled)
        _dateCompleted = State(wrappedValue: workout.workoutDateCompleted)
        _completed = State(wrappedValue: workout.completed)
    }

    var body: some View {
        Form {
            Section(header: Text("Workout ID")) {
                Text(workout.workoutId)
            }

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
                ForEach(workout.workoutExercises, id: \.self) { exercise in
                    Section(header: Text(exercise.exerciseName)) {
                        HStack {
                            Text("\(Int(100 * exerciseCompletionAmount(exercise)))%")
                            ProgressView(value: exerciseCompletionAmount(exercise))
                        }

                        ForEach(filterExerciseSets(exercise.exerciseSets), id: \.self) { exerciseSet in
                            ExerciseSetView(exerciseSet: exerciseSet)
                                .swipeActions(edge: .leading) {
                                    Button {
                                        withAnimation {
                                            exerciseSet.completed.toggle()
                                            update()
                                        }
                                    } label: {
                                        if exerciseSet.completed {
                                            Label("Mark Incomplete", systemImage: "xmark")
                                        } else {
                                            Label("Complete", systemImage: "checkmark")
                                        }
                                    }
                                    .tint(exerciseSet.completed
                                          ? .red
                                          : .green)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            print("ExerciseSet deleted: \(exerciseSet.exerciseSetId)")
                                            deleteExerciseSet(exerciseSet: exerciseSet)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }

                        Button("Add Set") {
                            withAnimation {
                                addSet(toExercise: exercise, toWorkout: workout)
                                print("A set was added to the exercise.")
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

            Section(header: Text("Complete a workout when you've finished every set for all exercises.")) {
                Toggle("Complete workout", isOn: $completed.onChange {
                    showingCompleteConfirmation = true
                    getConfirmationAlertTitleAndMessage()
                })
                .alert(isPresented: $showingCompleteConfirmation) {
                    Alert(
                        title: Text(completeConfirmationTitle),
                        message: Text(completeConfirmationMessage),
                        dismissButton: .default(Text("OK")) {
                            update()
                        }
                    )
                }
            }

            Section(header: Text("Deleting a workout cannot be undone.")) {
                Button("Delete workout") {
                    showingDeleteConfirmation = true
                }
                .tint(.red)
                .alert(isPresented: $showingDeleteConfirmation) {
                    Alert(
                        title: Text("Are you sure?"),
                        message: Text("Deleting a workout cannot be undone."),
                        primaryButton: .destructive(Text("Delete"),
                                                      action: delete),
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .navigationTitle("Edit Workout")
        .onAppear { print(workout, workout.workoutExercises) }
        .onDisappear(perform: dataController.save)
    }

    func update() {
        workout.objectWillChange.send()

        workout.name = name
        workout.dateScheduled = dateScheduled
        workout.completed = completed

        if workout.completed && workout.dateCompleted == nil {
            workout.dateCompleted = Date()
        } else {
            workout.dateCompleted = dateCompleted
        }
    }

    func getConfirmationAlertTitleAndMessage() {
        if workout.completed {
            completeConfirmationTitle = "Workout Scheduled"
            completeConfirmationMessage = "This workout will now move to your scheduled workouts. Get after it!"
        } else {
            completeConfirmationTitle = "Workout Complete"
            completeConfirmationMessage = "Smashed it! This workout will now move to your workout history."
        }
    }

    func addSet(toExercise exercise: Exercise,
                toWorkout workout: Workout) {
        let set = ExerciseSet(context: dataController.container.viewContext)
        set.id = UUID()
        set.workout = workout
        set.exercise = exercise
        set.creationDate = Date()
        dataController.save()
    }

    func delete() {
        dataController.delete(workout)
        presentationMode.wrappedValue.dismiss()
    }

    func deleteExerciseSet(exerciseSet: ExerciseSet) {
        dataController.delete(exerciseSet)
        dataController.save()
    }

    func filterExerciseSets(_ exerciseSets: [ExerciseSet]) -> [ExerciseSet] {
        exerciseSets.filter { $0.workout == workout }.sorted(by: \ExerciseSet.exerciseSetCreationDate)
    }

    func exerciseCompletionAmount(_ exercise: Exercise) -> Double {
        let allSets = exercise.exerciseSets.filter { $0.workout == workout }
        guard allSets.isEmpty == false else { return 0 }

        let completedSets = allSets.filter { $0.completed == true }

        return Double(completedSets.count) / Double(allSets.count)
    }
}

struct EditWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        EditWorkoutView(workout: Workout.example)
    }
}
