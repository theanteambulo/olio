//
//  AddExerciseToWorkoutView.swift
//  Olio
//
//  Created by Jake King on 27/11/2021.
//

import SwiftUI

/// A view to add an exercise from the library to a given workout.
struct AddExerciseToWorkoutView: View {
    /// The workout used to construct this view.
    @ObservedObject var workout: Workout

    /// A fetch request of Exercise objects.
    let exercises: FetchRequest<Exercise>

    @State private var exerciseCategory = "Weights"

    /// The environment singleton responsible for managing the Core Data stack.
    @EnvironmentObject var dataController: DataController

    /// The object space in which all managed objects exist.
    @Environment(\.managedObjectContext) var managedObjectContext

    /// Provides functionality for dismissing a presentation.
    ///
    /// Used in this view for dismissing a sheet.
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

    /// Computed property to sort exercises by muscle group, then by name.
    ///
    /// Example: Bench comes before Flys in Chest, which both come before Squats in Legs.
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

    /// Computed property to filter out any exercises which have already been added to the workout.
    var filteredExercises: [Exercise] {
        filterByExerciseCategory(exerciseCategory,
                                 exercises: sortedExercises).filter { !workout.workoutExercises.contains($0) }
    }

    var body: some View {
        NavigationView {
            VStack {
                Picker(Strings.exerciseCategory.localized, selection: $exerciseCategory) {
                    Text(.weights).tag("Weights")
                    Text(.body).tag("Body")
                    Text(.cardio).tag("Cardio")
                    Text(.exerciseClass).tag("Class")
                    Text(.stretch).tag("Stretch")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                List {
                    ForEach(Exercise.MuscleGroup.allCases, id: \.rawValue) { muscleGroup in
                        Section(header: Text(muscleGroup.rawValue)) {
                            ForEach(filterExercisesToMuscleGroup(muscleGroup.rawValue,
                                                                 exercises: filteredExercises)) { exercise in
                                Button {
                                    withAnimation {
                                        addExerciseToWorkout(exercise)
                                        dismiss()
                                    }
                                } label: {
                                    HStack {
                                        Circle()
                                            .frame(width: 7)
                                            .foregroundColor(exercise.getExerciseCategoryColor())

                                        Text(exercise.exerciseName)
                                    }
                                    .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(Text(.addExercise))
        }
    }

    /// Filters a given array of exercises based on whether their muscleGroup property matches a given muscle group.
    /// - Parameters:
    ///   - muscleGroup: The muscle group to filter the array of exercises by.
    ///   - exercises: The array of exercises to filter.
    /// - Returns: An array of exercises.
    func filterExercisesToMuscleGroup(_ muscleGroup: Exercise.MuscleGroup.RawValue,
                                      exercises: [Exercise]) -> [Exercise] {
        return exercises.filter { $0.exerciseMuscleGroup == muscleGroup }
    }

    func filterByExerciseCategory(_ exerciseCategory: Exercise.ExerciseCategory.RawValue,
                                  exercises: [Exercise]) -> [Exercise] {
        return exercises.filter { $0.exerciseCategory == exerciseCategory }
    }

    /// Updates the set of exercises that the workout is parent of to include a given exercise.
    /// - Parameter exercise: The exercise to make a child of the workout.
    func addExerciseToWorkout(_ exercise: Exercise) {
        workout.objectWillChange.send()

        var existingExercises = workout.workoutExercises
        existingExercises.append(exercise)

        workout.setValue(NSSet(array: existingExercises), forKey: "exercises")

        dataController.save()
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
