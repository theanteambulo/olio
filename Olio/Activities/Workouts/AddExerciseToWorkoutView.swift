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

    /// The exercise category selected by the user.
    @State private var exerciseCategory = "Weights"

    /// The array of Exercise objects to add to the workout.
    @State private var exercisesToAdd = [Exercise]()

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

    /// An array of Exercise objects.
    var exercisesArray: [Exercise] {
        exercises.wrappedValue.map({ $0 })
    }

    /// An array of Exercise objects.
    var exercisesArraySortedByPosition: [Exercise] {
        exercisesArray.sorted { first, second in
            let firstIndex = dataController.getPlacement(forExercise: first, inWorkout: workout)
            let secondIndex = dataController.getPlacement(forExercise: second, inWorkout: workout)

            if  firstIndex ?? 0 < secondIndex ?? 0 {
                return true
            } else {
                return false
            }
        }
    }

    /// Computed property to filter out any exercises which have already been added to the workout.
    var filteredExercises: [Exercise] {
        filterByExerciseCategory(exerciseCategory,
                                 exercises: exercisesArray)
    }

    /// The muscle groups the exercises passed in belong to.
    var muscleGroups: [Exercise.MuscleGroup.RawValue] {
        filteredExercises.compactMap({ $0.exerciseMuscleGroup }).removingDuplicates()
    }

    /// Toolbar button used to add exercises to the workout.
    var addExercisesToolbarButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(Strings.addExercisesToWorkout.localized) {
                dataController.addExercises(exercisesToAdd, toWorkout: workout)
                dismiss()
            }
        }
    }

    /// Toolbar button used to dismiss the sheet.
    var dismissSheetToolbarButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                dismiss()
            } label: {
                Label("Close", systemImage: "xmark")
            }
        }
    }

    var body: some View {
        NavigationView {
            Group {
                if !exercisesArray.isEmpty {
                    VStack {
                        Picker(Strings.exerciseCategory.localized, selection: $exerciseCategory) {
                            Text(.weights).tag("Weights")
                            Text(.body).tag("Body")
                            Text(.cardio).tag("Cardio")
                            Text(.exerciseClass).tag("Class")
                            Text(.stretch).tag("Stretch")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)

                        List {
                            ForEach(muscleGroups, id: \.self) { muscleGroup in
                                Section(header: Text(muscleGroup)) {
                                    ForEach(filterExercisesToMuscleGroup(muscleGroup,
                                                                         exercises: filteredExercises)) { exercise in
                                        Button {
                                            if exercisesToAdd.contains(exercise) {
                                                removeFromExerciseToAdd(exercise)
                                            } else {
                                                appendToExerciseToAdd(exercise)
                                            }
                                        } label: {
                                            HStack {
                                                Circle()
                                                    .frame(width: 7)
                                                    .foregroundColor(exercise.getExerciseCategoryColor())

                                                Text(exercise.exerciseName)

                                                Spacer()

                                                Image(systemName: "checkmark")
                                                    .foregroundColor(exercisesToAdd.contains(exercise)
                                                                     ? .secondary
                                                                     : .clear)

                                                Text("\((exercisesToAdd.firstIndex(of: exercise) ?? -2) + 1)")
                                                    .foregroundColor(exercisesToAdd.contains(exercise)
                                                                     ? .secondary
                                                                     : .clear)
                                                    .font(.caption)
                                            }
                                            .foregroundColor(.primary)
                                        }
                                        .accessibilityElement(children: .ignore)
                                        .accessibility(identifier: exercise.exerciseName)
                                    }
                                }
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                } else {
                    AddOlioLibraryView()
                }
            }
            .navigationTitle(Text(.addExercise))
            .toolbar {
                dismissSheetToolbarButton
                addExercisesToolbarButton
            }
            .onAppear {
                exercisesToAdd = exercisesArraySortedByPosition.filter({ workout.workoutExercises.contains($0) })
            }
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

    /// Filters a given array of Exercise objects by a given exercise category.
    /// - Parameters:
    ///   - exerciseCategory: The exercise category to filter by.
    ///   - exercises: The array of Exercise objects to filter.
    /// - Returns: An array of Exercise objects.
    func filterByExerciseCategory(_ exerciseCategory: Exercise.ExerciseCategory.RawValue,
                                  exercises: [Exercise]) -> [Exercise] {
        return exercises.filter { $0.exerciseCategory == exerciseCategory }
    }

    /// Appends an Exercise object to an array of Exercise objects to be added to the Workout when the user dismisses
    /// the view.
    /// - Parameter exercise: The Exercise object to append.
    func appendToExerciseToAdd(_ exercise: Exercise) {
        exercisesToAdd.append(exercise)
    }

    /// Removes an Exercise object from an array of Exercise objects to be added to the Workout when the user dismisses
    /// the view.
    /// - Parameter exercise: The Exercise object to remove.
    func removeFromExerciseToAdd(_ exercise: Exercise) {
        exercisesToAdd.removeAll(where: { $0.id == exercise.id })
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
