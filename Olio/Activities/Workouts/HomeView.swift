//
//  NewHomeView.swift
//  Olio
//
//  Created by Jake King on 09/01/2022.
//

import SwiftUI

/// A view to display the user's workouts and, conditionally, templates.
///
/// Note templates will only be displayed when the showingCompletedWorkouts Boolean is set to false. When this is the
/// case, the list of workouts displayed will be conditional on their completed property value.
struct NewHomeView: View {
    /// The presentation model representing the state of this view capable of reading model data and carrying out all
    /// transformations required to prepare that data for presentation.
    @StateObject var viewModel: ViewModel

    /// Tag value for the "Home" tab.
    static let homeTag: String? = "Home"
    /// Tag value for the "History" tab.
    static let historyTag: String? = "History"

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

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Display templates if on the "Home" tab.
                if !showingCompletedWorkouts {
                    TemplatesView(dataController: dataController)
                }

                List {
                    // Add a new workout - displayed only when not viewing completed workouts.
                    if !showingCompletedWorkouts {
                        Button {
                            withAnimation {
                                addWorkout()
                            }
                        } label: {
                            Label(Strings.newWorkout.localized, systemImage: "plus")
                        }
                    }

                    ForEach(workoutDates, id: \.self) { date in
                        Section(header: Text("\(date.formatted(date: .complete, time: .omitted))")) {
                            // Display list of workouts, if any exist.
                            WorkoutsListView(dataController: dataController,
                                             showingCompletedWorkouts: showingCompletedWorkouts,
                                             workoutsOnDate: date)
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
        NewHomeView()
    }
}
