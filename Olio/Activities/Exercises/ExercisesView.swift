//
//  ExercisesView.swift
//  Olio
//
//  Created by Jake King on 23/11/2021.
//

import SwiftUI

struct ExercisesView: View {
    @StateObject var viewModel: ViewModel

    static let tag: String? = "Exercises"

    @State private var showingAddExerciseSheet = false

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
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
                        ForEach(viewModel.filterByMuscleGroup(muscleGroup.rawValue,
                                                                       exercises: viewModel.exercises)) { exercise in
                            ExerciseRowView(exercise: exercise)
                        }
                        .onDelete { offsets in
                            let muscleGroupExercises = viewModel.filterByMuscleGroup(muscleGroup.rawValue,
                                                                                     exercises: viewModel.exercises)

                            for offset in offsets {
                                viewModel.swipeToDeleteExercise(exercises: muscleGroupExercises,
                                                                at: offset)
                            }
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
}

struct ExercisesView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        ExercisesView(dataController: DataController.preview)
    }
}
