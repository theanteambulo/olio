//
//  WorkoutDateConfirmationDialog.swift
//  Olio
//
//  Created by Jake King on 07/01/2022.
//

import SwiftUI

struct WorkoutDateConfirmationDialog: View {
    /// The workout object used to construct this view.
    @ObservedObject var workout: Workout

    /// The environment singleton responsible for managing the Core Data stack.
    @EnvironmentObject var dataController: DataController

    /// The workout's date property value.
    @State private var date: Date

    init(workout: Workout) {
        self.workout = workout
        _date = State(wrappedValue: workout.workoutDate)
    }

    var body: some View {
        Group {
            Button(Strings.today.localized) {
                saveNewWorkoutDate(dayOffset: 0)

                if workout.template {
                    dataController.createNewWorkoutOrTemplateFromExisting(workout,
                                                                          isTemplate: false,
                                                                          scheduledOn: date)
                }

                update()
                dataController.save()
            }

            Button(Strings.tomorrow.localized) {
                saveNewWorkoutDate(dayOffset: 1)

                if workout.template {
                    dataController.createNewWorkoutOrTemplateFromExisting(workout,
                                                                          isTemplate: false,
                                                                          scheduledOn: date)
                }

                update()
                dataController.save()
            }

            ForEach(2...7, id: \.self) { dayOffset in
                Button("\(getDateOption(dayOffset).formatted(date: .complete, time: .omitted))") {
                    saveNewWorkoutDate(dayOffset: Double(dayOffset))

                    if workout.template {
                        dataController.createNewWorkoutOrTemplateFromExisting(workout,
                                                                              isTemplate: false,
                                                                              scheduledOn: date)
                    }

                    update()
                    dataController.save()
                }
            }
        }
    }

    /// Returns a date offset by a given number of days from today.
    /// - Parameter dayOffset: The number of days offset from the current date the workout option will be.
    /// - Returns: A date offset by a given number of days from today.
    func getDateOption(_ dayOffset: Int) -> Date {
        let dateOption = Date.now + Double(dayOffset * 86400)
        return dateOption
    }

    /// Saves the new workout date the user selected.
    /// - Parameter dayOffset: The number of days offset from the current date the workout is scheduled on.
    func saveNewWorkoutDate(dayOffset: Double) {
        date = Date.now + (dayOffset * 86400)
    }

    /// Synchronise the @State properties of the view with their Core Data equivalents in whichever Workout
    /// object is being edited.
    ///
    /// Changes will be announced to any property wrappers observing the workout.
    func update() {
        workout.objectWillChange.send()

        workout.date = date
    }
}

struct WorkoutDateConfirmationDialog_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutDateConfirmationDialog(workout: Workout.example)
    }
}
