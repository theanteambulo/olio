//
//  ExercisesView.swift
//  Olio
//
//  Created by Jake King on 23/11/2021.
//

import SwiftUI

struct ExercisesView: View {
    let exercises: FetchRequest<Exercise>

    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var managedObjectContext

    static let tag: String? = "Exercises"

    @State private var showingAddExerciseSheet = false

    init() {
        exercises = FetchRequest<Exercise>(
            entity: Exercise.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.muscleGroup, ascending: true),
                              NSSortDescriptor(keyPath: \Exercise.name, ascending: true)]
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

    var addExerciseToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showingAddExerciseSheet.toggle()
            } label: {
                Label("Add", systemImage: "plus")
            }
            .sheet(isPresented: $showingAddExerciseSheet) {
                AddExerciseView()
            }
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(Exercise.MuscleGroup.allCases, id: \.rawValue) { muscleGroup in
                    Section(header: Text(muscleGroup.rawValue)) {
                        ForEach(filterExercisesToMuscleGroup(muscleGroup.rawValue,
                                                             exercises: sortedExercises)) { exercise in
                            ExerciseRowView(exercise: exercise)
                        }
                        .onDelete { offsets in
                            let muscleGroupExercises = filterExercisesToMuscleGroup(muscleGroup.rawValue,
                                                                                    exercises: sortedExercises)

                            for offset in offsets {
                                let exercise = muscleGroupExercises[offset]
                                dataController.delete(exercise)
                            }

                            dataController.save()
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(Text(.exercisesTab))
            .toolbar {
                addExerciseToolbarItem
            }
        }
    }

    func filterExercisesToMuscleGroup(_ muscleGroup: Exercise.MuscleGroup.RawValue,
                                      exercises: [Exercise]) -> [Exercise] {
        return exercises.filter {$0.exerciseMuscleGroup == muscleGroup}
    }
}

struct ExercisesView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        ExercisesView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
