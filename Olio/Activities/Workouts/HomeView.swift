//
//  HomeView.swift
//  Olio
//
//  Created by Jake King on 09/01/2022.
//

import SwiftUI

/// A view to display the user's workouts and, conditionally, templates.
///
/// Note templates will only be displayed when the showingCompletedWorkouts Boolean is set to false. When this is the
/// case, the list of workouts displayed will be conditional on their completed property value.
struct HomeView: View {
    /// The presentation model representing the state of this view capable of reading model data and carrying out all
    /// transformations required to prepare that data for presentation.
    @StateObject var viewModel: ViewModel

    /// Boolean to indicate whether a confirmation dialog is being shown. Toggled when a user swipes to reschedule.
    @State private var showingSwipeToRescheduleDialog = false

    /// Tag value for the "Home" tab.
    static let homeTag: String? = "Home"
    /// Tag value for the "History" tab.
    static let historyTag: String? = "History"

    init(dataController: DataController, showingCompletedWorkouts: Bool) {
        let viewModel = ViewModel(dataController: dataController,
                              showingCompletedWorkouts: showingCompletedWorkouts)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    /// Computed property to get the text displayed in the navigation title of the view.
    var navigationTitleLocalizedStringKey: Text {
        viewModel.showingCompletedWorkouts
        ? Text(.historyTab)
        : Text(.homeTab)
    }

    /// Toolbar button to add sample data to the app.
    var deleteAllDataToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Delete Data") {
                viewModel.deleteAll()
            }
        }
    }

    /// Computed property that derives the label of the button used to change the completion status of a workout when
    /// the user swipes from the leading edge.
    var swipeToToggleCompletionStatusLabel: some View {
        if viewModel.showingCompletedWorkouts {
            return Label(Strings.incompleteButton.localized, systemImage: "xmark.circle")
                .labelStyle(.titleAndIcon)
        } else {
            return Label(Strings.completeButton.localized, systemImage: "checkmark.circle")
                .labelStyle(.titleAndIcon)
        }
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Display templates if on the "Home" tab.
                if !viewModel.showingCompletedWorkouts {
                    TemplatesView(dataController: viewModel.dataController)
                }

                List {
                    // Add a new workout - displayed only when not viewing completed workouts.
                    if !viewModel.showingCompletedWorkouts {
                        Button {
                            withAnimation {
                                viewModel.addWorkout()
                            }
                        } label: {
                            Label(Strings.newWorkout.localized, systemImage: "plus")
                        }
                    }

                    ForEach(viewModel.workoutDates.sorted(), id: \.self) { date in
                        Section(header: Text("\(date.formatted(date: .complete, time: .omitted))")) {
                            // Display list of workouts, if any exist.
                            ForEach(viewModel.filterWorkouts(viewModel.workouts, by: date), id: \.self) { workout in
                                WorkoutRowView(workout: workout)
                                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                        // Complete/incomplete workout
                                        Button {
                                            withAnimation {
                                                viewModel.toggleCompletionStatusForWorkout(workout)
                                            }
                                        } label: {
                                            swipeToToggleCompletionStatusLabel
                                        }
                                        .tint(workout.completed ? .orange : .green)
                                    }
                                    .swipeActions(edge: .trailing) {
                                        // Delete workout
                                        Button {
                                            withAnimation {
                                                viewModel.deleteWorkout(workout)
                                            }
                                        } label: {
                                            Label(Strings.deleteButton.localized, systemImage: "trash")
                                                .labelStyle(.titleAndIcon)
                                        }
                                        .tint(.red)
                                    }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .padding(.bottom)
            .navigationTitle(navigationTitleLocalizedStringKey)
            .toolbar {
                deleteAllDataToolbarItem
            }
        }
    }
}

struct NewHomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(dataController: DataController.preview, showingCompletedWorkouts: false)
    }
}
