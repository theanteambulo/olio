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
                Label(Strings.addExercise.localized, systemImage: "plus")
            }
            .accessibilityIdentifier("Add new exercise")
            .sheet(isPresented: $showingAddExerciseSheet) {
                AddExerciseView(currentlyActiveExerciseCategory: viewModel.exerciseCategory)
            }
        }
    }

    var body: some View {
        NavigationView {
            Group {
                if !viewModel.exercises.isEmpty {
                    VStack {
                        Picker(Strings.exerciseCategory.localized, selection: $viewModel.exerciseCategory) {
                            Text(.weights).tag("Free Weights")
                            Text(.body).tag("Bodyweight")
//                            Text(.cardio).tag("Cardio")
//                            Text(.exerciseClass).tag("Class")
//                            Text(.stretch).tag("Stretch")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)

                        ExerciseListView(dataController: viewModel.dataController,
                                         exercises: viewModel.sortedExercises)
                    }
                } else {
                    AddOlioLibraryView()
                }
            }
            .navigationTitle(Text(.exercisesTab))
            .navigationBarTitleDisplayMode(.large)
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
