//
//  ScheduledWorkoutsView.swift
//  Olio
//
//  Created by Jake King on 30/11/2021.
//

import CoreData
import SwiftUI

struct ScheduledWorkoutsView: View {
    let templates: FetchRequest<Workout>
    let workouts: FetchRequest<Workout>

    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var managedObjectContext

    static let scheduledTag: String? = "Scheduled"

    @State private var showingAddConfirmationDialog = false

    var rows: [GridItem] {
        [GridItem(.fixed(100))]
    }

    var sortedWorkouts: [Workout] {
        return workouts.wrappedValue.sorted { first, second in
            if first.workoutDate < second.workoutDate {
                return true
            } else if first.workoutDate > second.workoutDate {
                return false
            }

            return first.workoutName < second.workoutName
        }
    }

    var workoutDates: [Date] {
        var dates = [Date]()

        for workout in sortedWorkouts {
            if !dates.contains(Calendar.current.startOfDay(for: workout.workoutDate)) {
                dates.append(Calendar.current.startOfDay(for: workout.workoutDate))
            }
        }

        return dates
    }

    init() {
        // Get all the templates.
        let templatesRequest: NSFetchRequest<Workout> = Workout.fetchRequest()

        let templateRequestPredicate = NSPredicate(format: "template = true")
        templatesRequest.predicate = NSCompoundPredicate(type: .and,
                                                         subpredicates: [templateRequestPredicate])
        templatesRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.name,
                                                             ascending: true)]

        templates = FetchRequest(fetchRequest: templatesRequest)

        // Get the next 10 scheduled workouts.
        let workoutsRequest: NSFetchRequest<Workout> = Workout.fetchRequest()

        let completedPredicate = NSPredicate(format: "completed = false")
        let templatePredicate = NSPredicate(format: "template != true")
        workoutsRequest.predicate = NSCompoundPredicate(type: .and,
                                                        subpredicates: [completedPredicate,
                                                                        templatePredicate])
        workoutsRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Workout.date,
                             ascending: true),
            NSSortDescriptor(keyPath: \Workout.name,
                             ascending: true)
        ]

        workoutsRequest.fetchLimit = 10

        workouts = FetchRequest(fetchRequest: workoutsRequest)
    }

    var addWorkoutToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showingAddConfirmationDialog = true
            } label: {
                Label("Add", systemImage: "plus")
            }
            .confirmationDialog(Text(.selectOption),
                                isPresented: $showingAddConfirmationDialog) {
                Button(Strings.newTemplate.localized) {
                    withAnimation {
                        let workout = Workout(context: managedObjectContext)
                        workout.id = UUID()
                        workout.date = Date()
                        workout.completed = false
                        workout.template = true
                        dataController.save()
                    }
                }

                Button(Strings.newWorkout.localized) {
                    withAnimation {
                        let workout = Workout(context: managedObjectContext)
                        workout.id = UUID()
                        workout.date = Date()
                        workout.completed = false
                        workout.template = false
                        dataController.save()
                    }
                }

                Button(Strings.cancelButton.localized, role: .cancel) {
                    showingAddConfirmationDialog = false
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            Group {
                VStack(alignment: .leading) {
                    Text(.workoutTemplates)
                        .padding(.leading)
                        .font(.title3)

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: rows) {
                            ForEach(templates.wrappedValue) { template in
                                TemplateCardView(template: template)
                            }
                        }
                        .padding(.horizontal)
                        .fixedSize(horizontal: false,
                                   vertical: true)
                    }
                    .padding(.bottom)

                    Text(.workoutsScheduled)
                        .padding(.leading)
                        .font(.title3)

                    if sortedWorkouts.isEmpty {
                        Spacer()

                        HStack {
                            Spacer()

                            Text(.nothingToSeeHere)
                                .padding(.horizontal)

                            Spacer()
                        }

                        Spacer()
                    } else {
                        List {
                            ForEach(workoutDates, id: \.self) { date in
                                Section(header: Text(date.formatted(date: .complete, time: .omitted))) {
                                    WorkoutsListView(date: date, workouts: sortedWorkouts)
                                }
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                }
            }
            .padding(.bottom)
            .navigationTitle(Strings.homeTab.localized)
            .toolbar {
                addWorkoutToolbarItem
            }
        }
    }
}

struct ScheduledWorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduledWorkoutsView()
    }
}
