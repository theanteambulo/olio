//
//  TemplateCardView.swift
//  Olio
//
//  Created by Jake King on 01/12/2021.
//

import CoreHaptics
import SwiftUI

/// A single card representing a given workout template.
struct TemplateCardView: View {
    /// The workout template used to construct this view.
    @ObservedObject var template: Workout

    /// The environment singleton responsible for managing our Core Data stack.
    @EnvironmentObject var dataController: DataController

    /// The array of colors corresponding to unique exercise categories in this workout.
    private var exerciseCategoryColors: [Color]

    /// An array of Boolean values indicating whether a circle should be filled or not.
    private var fillCircle: [Bool]

    /// A grid with a single row.
    var rows: [GridItem] {
        Array(repeating: GridItem(.fixed(7)), count: 1)
    }

    /// Boolean to indicate whether the template destination from the navigation link is active or not.
    @State private var navigationLinkIsActive = false
    /// Boolean to indicate whether the popover for the template card is active or not.
    @State private var showingTakeActionAlert = false
    /// Boolean to indicate whether the date selection confirmation dialog is visible or not.
    @State private var showingCreateWorkoutConfirmation = false
    /// Boolean to indicate whether the delete warning alert is active or not.
    @State private var showingDeleteWarningAlert = false
    /// The instance of CHHapticEngine responsible for spinning up the Taptic Engine.
    @State private var engine = try? CHHapticEngine()

    init(template: Workout) {
        self.template = template
        exerciseCategoryColors = Exercise.allExerciseCategoryColors.map({ $0.value })

        let workoutExerciseCategoryColors = template.workoutExercises.sorted(by: \.exerciseCategory).map({
            $0.getExerciseCategoryColor()
        })

        fillCircle = exerciseCategoryColors.map({ workoutExerciseCategoryColors.contains($0) })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(template.workoutName)")
                .foregroundColor(.primary)
                .font(.headline)
                .frame(minWidth: 125,
                       alignment: .leading)

            if !template.workoutExercises.isEmpty {
                LazyHGrid(rows: rows, spacing: 7) {
                    ForEach(Array(zip(exerciseCategoryColors.indices,
                                      exerciseCategoryColors)), id: \.1) { index, categoryColor in
                        Circle()
                            .strokeBorder(categoryColor, lineWidth: 1)
                            .background(Circle().fill(fillCircle[index] ? categoryColor : .clear))
                            .frame(width: 7)
                    }
                }
            }

            Group {
                Text("\(template.workoutExercises.count) exercises")

                Text("\(template.workoutExerciseSets.count) sets")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(10)
        .frame(maxHeight: .infinity)
        .background(Color.secondarySystemGroupedBackground)
        .cornerRadius(5)
        .contentShape(RoundedRectangle(cornerRadius: 5))
        .background(
            NavigationLink(
                "\(template.workoutName)",
                destination: EditWorkoutView(workout: template),
                isActive: $navigationLinkIsActive
            )
            .accessibilityHidden(true)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(template.workoutName)
        .onTapGesture {
            navigationLinkIsActive = true
        }
        .onLongPressGesture(minimumDuration: 0.3) {
            showingTakeActionAlert = true

            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        .alert(Text(.takeAction), isPresented: $showingTakeActionAlert) {
            Button(Strings.createWorkoutFromTemplateButton.localized) {
                showingCreateWorkoutConfirmation = true
            }

            Button(Strings.deleteTemplateButton.localized, role: .destructive) {
                if template.workoutExercises.count != 0 {
                    showingDeleteWarningAlert = true
                } else {
                    dataController.delete(template)
                }

                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            }
        }
        .alert(Text(.areYouSureAlertTitle), isPresented: $showingDeleteWarningAlert) {
            Button(Strings.deleteButton.localized, role: .destructive) {
                dataController.delete(template)
            }
        } message: {
            Text(.deleteTemplateConfirmationMessage)
        }
        .confirmationDialog(Strings.scheduleWorkout.localized,
                            isPresented: $showingCreateWorkoutConfirmation) {
            WorkoutDateConfirmationDialog(workout: template)
        } message: {
            Text(.selectWorkoutDateMessage)
        }
    }
}

struct TemplateCardView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateCardView(template: Workout.example)
    }
}
