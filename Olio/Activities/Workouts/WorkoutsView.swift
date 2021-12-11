//
//  WorkoutsView.swift
//  Olio
//
//  Created by Jake King on 03/12/2021.
//

import CoreData
import SwiftUI

/// A view to display the user's workouts and, conditionally, templates.
///
/// Note templates will only be displayed when the showingCompletedWorkouts Boolean is set to false. When this is the
/// case, the list of workouts displayed will be conditional on their completed property value.
struct WorkoutsView: View {
    /// The presentation model representing the state of this view capable of reading model data and carrying out all
    /// transformations needed to prepare that data for presentation.
    @StateObject var viewModel: ViewModel

    /// Tag value for the "Home" tab.
    static let homeTag: String? = "Home"

    /// Tag value for the "History" tab.
    static let historyTag: String? = "History"

    /// Boolean indicating whether the action sheet used to add a new template or exercise is displayed.
    @State private var showingAddConfirmationDialog = false

    init(dataController: DataController,
         showingCompletedWorkouts: Bool) {
        let viewModel = ViewModel(dataController: dataController,
                                  showingCompletedWorkouts: showingCompletedWorkouts)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    /// Computed property to get the text displayed in the navigation title of the view.
    ///
    /// Conditional on whether completed or scheduled workouts are being displayed.
    var navigationTitleLocalizedStringKey: Text {
        viewModel.showingCompletedWorkouts
        ? Text(.historyTab)
        : Text(.homeTab)
    }

    /// Toolbar button that displays an action sheet to add a new template or workout.
    var addWorkoutToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if !viewModel.showingCompletedWorkouts {
                Button {
                    showingAddConfirmationDialog = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
                .confirmationDialog(Text(.selectOption),
                                    isPresented: $showingAddConfirmationDialog) {
                    Button(Strings.newTemplate.localized) {
                        withAnimation {
                            viewModel.addTemplate()
                        }
                    }
                    .accessibilityIdentifier("Add New Template")

                    Button(Strings.newWorkout.localized) {
                        withAnimation {
                            viewModel.addWorkout()
                        }
                    }
                    .accessibilityIdentifier("Add New Workout")

                    Button(Strings.cancelButton.localized, role: .cancel) {
                        showingAddConfirmationDialog = false
                    }
                }
            }
        }
    }

    /// Toolbar button to add sample data to the app.
    var addSampleDataToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Sample Data") {
                viewModel.createSampleData()
            }
        }
    }

    /// The list of workouts to be displayed.
    var workoutsList: some View {
        List {
            ForEach(viewModel.workoutDates, id: \.self) { date in
                Section(header: Text(date.formatted(date: .complete, time: .omitted))) {
                    ForEach(viewModel.filterByDate(date,
                                                   workouts: viewModel.sortedWorkouts)) { workout in
                        WorkoutRowView(workout: workout)
                    }
                    .onDelete { offsets in
                        let allWorkouts = viewModel.filterByDate(date,
                                                                 workouts: viewModel.sortedWorkouts)

                        for offset in offsets {
                            withAnimation {
                                viewModel.swipeToDeleteWorkout(allWorkouts, at: offset)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }

    var body: some View {
        NavigationView {
            Group {
                VStack(alignment: .leading) {
                    // Display templates if on the "Home" tab.
                    if !viewModel.showingCompletedWorkouts {
                        TemplatesView(dataController: viewModel.dataController)
                    }

                    // Display list of workouts, if any exist.
                    if viewModel.sortedWorkouts.isEmpty {
                        Spacer()

                        HStack {
                            Spacer()

                            Text(.nothingToSeeHere)
                                .padding(.horizontal)

                            Spacer()
                        }

                        Spacer()
                    } else {
                        workoutsList
                    }
                }
            }
            .padding(.bottom)
            .navigationTitle(navigationTitleLocalizedStringKey)
            .toolbar {
                addSampleDataToolbarItem
                addWorkoutToolbarItem
            }
        }
    }
}

struct WorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsView(dataController: DataController.preview,
                     showingCompletedWorkouts: true)
    }
}
