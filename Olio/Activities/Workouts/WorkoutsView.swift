//
//  WorkoutsView.swift
//  Olio
//
//  Created by Jake King on 03/12/2021.
//

import CoreData
import SwiftUI

struct WorkoutsView: View {
    @StateObject var viewModel: ViewModel

    static let scheduledTag: String? = "Scheduled"
    static let historyTag: String? = "History"

    @State private var showingAddConfirmationDialog = false

    init(dataController: DataController,
         showingCompletedWorkouts: Bool) {
        let viewModel = ViewModel(dataController: dataController,
                                  showingCompletedWorkouts: showingCompletedWorkouts)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // Don't like this. How to fix so can move to ViewModel?
    var navigationTitleLocalizedStringKey: Text {
        viewModel.showingCompletedWorkouts
        ? Text(.historyTab)
        : Text(.homeTab)
    }

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

    var addSampleDataToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Sample Data") {
                viewModel.createSampleData()
            }
        }
    }

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
                    if !viewModel.showingCompletedWorkouts {
                        TemplatesView(dataController: viewModel.dataController)
                    }

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
