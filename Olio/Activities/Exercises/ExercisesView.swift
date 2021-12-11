//
//  ExercisesView.swift
//  Olio
//
//  Created by Jake King on 23/11/2021.
//

import SwiftUI

/// A view to display a list of all exercises in the user's "library".
struct ExercisesView: View {
    /// The presentation model representing the state of this view capable of reading model data and carrying out all
    /// transformations needed to prepare that data for presentation.
    @StateObject var viewModel: ViewModel

    /// The tag value for the "Exercises" tab.
    static let tag: String? = "Exercises"

    /// Boolean to indicate whether the sheet used to add a new exercise is displayed.
    @State private var showingAddExerciseSheet = false

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    /// Toolbar button that displays a sheet containing AddExerciseView.
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
                        ForEach(
                            viewModel.filterByMuscleGroup(muscleGroup.rawValue,
                                                          exercises: viewModel.sortedExercises)) { exercise in
                            ExerciseRowView(exercise: exercise)
                        }
                        .onDelete { offsets in
                            let allExercises = viewModel.filterByMuscleGroup(muscleGroup.rawValue,
                                                                             exercises: viewModel.sortedExercises)

                            for offset in offsets {
                                viewModel.swipeToDeleteExercise(exercises: allExercises,
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
