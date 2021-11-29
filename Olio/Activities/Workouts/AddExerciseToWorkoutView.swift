//
//  AddExerciseToWorkoutView.swift
//  Olio
//
//  Created by Jake King on 27/11/2021.
//

import SwiftUI

struct AddExerciseToWorkoutView: View {
    @ObservedObject var workout: Workout
    let exercises: FetchRequest<Exercise>

    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss

    init(workout: Workout) {
        self.workout = workout

        exercises = FetchRequest<Exercise>(
            entity: Exercise.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.muscleGroup,
                                               ascending: true),
                              NSSortDescriptor(keyPath: \Exercise.name,
                                               ascending: true)]
        )
    }

    var sortedExercises: [Exercise] {
        return exercises.wrappedValue.sorted { first, second in
            if first.muscleGroup < second.muscleGroup {
                return true
            } else if first.muscleGroup > second.muscleGroup {
                return false
            }

            return first.exerciseName < second.exerciseName
        }
    }

    var filteredExercises: [Exercise] {
        sortedExercises.filter { !workout.workoutExercises.contains($0) }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(Exercise.MuscleGroup.allCases, id: \.rawValue) { muscleGroup in
                    Section(header: Text(muscleGroup.rawValue)) {
                        ForEach(filterExercisesToMuscleGroup(muscleGroup.rawValue,
                                                             exercises: filteredExercises)) { exercise in
                            Button {
                                addExerciseToWorkout(exercise)
                                dismiss()
                            } label: {
                                HStack {
                                    Text(exercise.exerciseName)
                                }
                                .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Exercise")
        }
    }

    func filterExercisesToMuscleGroup(_ muscleGroup: Exercise.MuscleGroup.RawValue,
                                      exercises: [Exercise]) -> [Exercise] {
        return exercises.filter {$0.exerciseMuscleGroup == muscleGroup}
    }

    func addExerciseToWorkout(_ exercise: Exercise) {
        workout.objectWillChange.send()

        var existingExercises = workout.workoutExercises
        existingExercises.append(exercise)

        workout.setValue(NSSet(array: existingExercises), forKey: "exercises")

        dataController.save()

        print("Workout exercises: \(workout.workoutExercises)")
        print("Exercise workouts: \(exercise.exerciseWorkouts)")
    }
}

struct AddExerciseToWorkoutView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        AddExerciseToWorkoutView(workout: Workout.example)
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
