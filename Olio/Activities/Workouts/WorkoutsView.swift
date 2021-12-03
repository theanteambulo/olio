//
//  WorkoutsView.swift
//  Olio
//
//  Created by Jake King on 03/12/2021.
//

import CoreData
import SwiftUI

struct WorkoutsView: View {
    let templates: FetchRequest<Workout>
    let workouts: FetchRequest<Workout>
    let showingCompletedWorkouts: Bool

    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var managedObjectContext

    static let scheduledTag: String? = "Scheduled"
    static let historyTag: String? = "History"

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

    var navigationTitleLocalizedStringKey: LocalizedStringKey {
        showingCompletedWorkouts
        ? Strings.historyTab.localized
        : Strings.homeTab.localized
    }

    init(showingCompletedWorkouts: Bool) {
        self.showingCompletedWorkouts = showingCompletedWorkouts

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

        let completedPredicate = NSPredicate(format: "completed = %d", showingCompletedWorkouts)
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

        if !showingCompletedWorkouts {
            workoutsRequest.fetchLimit = 10
        }

        workouts = FetchRequest(fetchRequest: workoutsRequest)
    }

    var addWorkoutToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if !showingCompletedWorkouts {
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
    }

    var workoutsList: some View {
        List {
            ForEach(workoutDates, id: \.self) { date in
                Section(header: Text(date.formatted(date: .complete, time: .omitted))) {
                    ForEach(filterWorkoutsByDate(date,
                                                 workouts: sortedWorkouts)) { workout in
                        WorkoutRowView(workout: workout)
                    }
                    .onDelete { offsets in
                        let allWorkouts = filterWorkoutsByDate(date,
                                                               workouts: sortedWorkouts)

                        for offset in offsets {
                            withAnimation {
                                let workoutToDelete = allWorkouts[offset]
                                dataController.delete(workoutToDelete)
                            }
                        }

                        dataController.save()
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }

    var workoutTemplates: some View {
        Group {
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
        }
    }

    var body: some View {
        NavigationView {
            Group {
                VStack(alignment: .leading) {
                    if !showingCompletedWorkouts {
                        workoutTemplates
                    }

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
                        workoutsList
                    }
                }
            }
            .padding(.bottom)
            .navigationTitle(Text(navigationTitleLocalizedStringKey))
            .toolbar {
                addWorkoutToolbarItem
            }
        }
    }

    func filterWorkoutsByDate(_ date: Date,
                              workouts: [Workout]) -> [Workout] {
        return workouts.filter { Calendar.current.startOfDay(for: $0.workoutDate) == date }
    }
}

struct WorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsView(showingCompletedWorkouts: true)
    }
}
