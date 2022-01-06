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

    /// Boolean to indicate whether the alert confirming the workout has been completed is displayed.
    @State private var showingCompleteConfirmation = false

    init(dataController: DataController,
         showingCompletedWorkouts: Bool) {
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

    /// Computed property that derives the title of an alert displayed when a user completes or schedules a workout.
    var completeRescheduleAlertTitle: Text {
        viewModel.showingCompletedWorkouts
        ? Text(.workoutScheduledAlertTitle)
        : Text(.workoutCompletedAlertTitle)
    }

    /// Computed property that derives the message of an alert displayed when a user completes or schedules a workout.
    var completeRescheduleAlertMessage: Text {
        viewModel.showingCompletedWorkouts
        ? Text(.workoutScheduledAlertMessage)
        : Text(.workoutCompletedAlertMessage)
    }

    /// Button copy used in alert presented after a user completes or reschedules a workout.
    var completeScheduleWorkoutButton: LocalizedStringKey {
        return viewModel.showingCompletedWorkouts
        ? Strings.rescheduleButton.localized
        : Strings.completeButton.localized
    }

    /// Toolbar button to add sample data to the app.
    var addSampleDataToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Sample Data") {
                viewModel.createSampleData()
            }
        }
    }

    /// The list of workouts to be displayed.
    var workoutsList: some View {
        List {
            if !viewModel.showingCompletedWorkouts {
                Button {
                    withAnimation {
                        viewModel.addWorkout()
                    }
                } label: {
                    Label(Strings.newWorkout.localized, systemImage: "plus")
                }
            }

            ForEach(viewModel.workoutDates, id: \.self) { date in
                Section(header: Text(date.formatted(date: .complete, time: .omitted))) {
                    ForEach(viewModel.filterByDate(date,
                                                   workouts: viewModel.sortedWorkouts)) { workout in
                        WorkoutRowView(workout: workout)
                            .swipeActions(edge: .leading) {
                                Button {
                                    showingCompleteConfirmation = true
                                } label: {
                                    if viewModel.showingCompletedWorkouts {
                                        Label(Strings.rescheduleButton.localized, systemImage: "calendar")
                                    } else {
                                        Label(Strings.completeButton.localized, systemImage: "checkmark.circle")
                                    }
                                }
                                .tint(viewModel.showingCompletedWorkouts ? .indigo : .green)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        viewModel.deleteWorkout(workout)
                                    }
                                } label: {
                                    Label(Strings.deleteButton.localized, systemImage: "trash")
                                        .labelStyle(.titleAndIcon)
                                }
                            }
                            .alert(completeRescheduleAlertTitle,
                                   isPresented: $showingCompleteConfirmation) {
                                Button(completeScheduleWorkoutButton) {
                                    viewModel.toggleWorkoutCompletionStatus(workout)
                                }

                                Button(Strings.cancelButton.localized, role: .cancel, action: { })
                            } message: {
                                completeRescheduleAlertMessage
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
                    workoutsList
                }
            }
            .padding(.bottom)
            .navigationTitle(navigationTitleLocalizedStringKey)
            .toolbar {
                addSampleDataToolbarItem
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
