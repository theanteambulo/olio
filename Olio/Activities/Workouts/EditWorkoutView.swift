//
//  EditWorkoutView.swift
//  Olio
//
//  Created by Jake King on 24/11/2021.
//

import CloudKit
import CoreHaptics
import SwiftUI

/// A view to edit the details of a given workout, including templates.
// swiftlint:disable:next type_body_length
struct EditWorkoutView: View {
    /// The Workout object used to construct this view.
    @ObservedObject var workout: Workout
    /// The array of Exercise objects used to construct this view.
    @State private var exercises = [Exercise]()

    /// The environment singleton responsible for managing the Core Data stack.
    @EnvironmentObject var dataController: DataController

    /// The object space in which all managed objects exist.
    @Environment(\.managedObjectContext) var managedObjectContext
    /// Allows for the view to be dismissed programmatically.
    @Environment(\.dismiss) var dismiss

    /// Checks for a valid username.
    @AppStorage("username") var username: String?

    /// Checks whether the onboarding journey should be showing.
    ///
    /// Should always be false in this view. Used in onboarding journey for showing SIWA sheet.
    @AppStorage("userOnboarded") var showingOnboardingJourney: Bool = false

    /// The workout's name property value.
    @State private var name: String
    /// Boolean to indicate whether the sheet used for adding an exercise to the workout is displayed.
    @State private var showingAddExerciseSheet = false
    /// Boolean to indicate whether the confirmation dialog used for changing the workout date is displayed.
    @State private var showingDateConfirmationDialog = false
    /// Boolean to indicate whether the alert confirming the workout has been completed is displayed.
    @State private var showingCompleteConfirmation = false
    /// Boolean to indicate whether the alert confirming a template will be created is displayed.
    @State private var showingCreateTemplateConfirmation = false
    /// Boolean to indicate whether the alert confirming a workout will be created is displayed.
    @State private var showingCreateWorkoutConfirmation = false
    /// Boolean to indicate whether the alert warning the user about deleting an exercise is displayed.
    @State private var showingDeleteWorkoutConfirmation = false
    /// Boolean to indicate whether the time picker is currently showing.
    @State private var remindUser: Bool
    /// The currently selected reminder time for the workout.
    @State private var reminderTime: Date
    /// Boolean to indicate whether the alert for error scheduling notifications is displayed.
    @State private var showingNotificationsAlert = false
    /// Boolean to indicate whether the alert for uploading a workout to iCloud is displayed.
    @State private var showingUploadWorkoutToCloudAlert = false
    /// Boolean to indicate whether the alert for removing a workout from iCloud is displayed.
    @State private var showingRemoveWorkoutFromCloudAlert = false
    /// Boolean to indicate whether the SIWA sheet is currently being displayed.
    @State private var showingSignInWithAppleSheet = false
    /// The instance of CHHapticEngine responsible for spinning up the Taptic Engine.
    @State private var engine = try? CHHapticEngine()
    /// Indicates whether the workout is currently stored in CloudKit or not.
    @State private var cloudStatus = CloudStatus.checking
    /// Stores any potential CloudKit error that has occurred.
    @State private var cloudError: CloudError?

    @FocusState private var isWorkoutNameFocused: Bool

    init(workout: Workout) {
        self.workout = workout

        _name = State(wrappedValue: workout.workoutName)

        if let workoutReminderTime = workout.reminderTime {
            _reminderTime = State(wrappedValue: workoutReminderTime)
            _remindUser = State(wrappedValue: true)
        } else {
            _reminderTime = State(wrappedValue: Date())
            _remindUser = State(wrappedValue: false)
        }
    }

    enum CloudStatus {
        case checking, exists, absent
    }

    /// Computed property to get the text displayed in the navigation title of the view.
    var navigationTitle: Text {
        workout.template ? Text(.editTemplateNavigationTitle) : Text(.editWorkoutNavigationTitle)
    }

    var keyboardDoneButton: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()

            Button("Done") {
                hideKeyboard()
            }
        }
    }

    /// Button that uploads the workout to iCloud.
    var uploadWorkoutToCloudToolbarButton: some View {
        Button {
//            showingUploadWorkoutToCloudAlert = true
            uploadWorkoutToCloud()
        } label: {
            Label(Strings.uploadWorkout.localized, systemImage: "icloud.and.arrow.up")
        }
//        .alert(Strings.uploadWorkout.localized,
//               isPresented: $showingUploadWorkoutToCloudAlert) {
//            Button(Strings.confirmButton.localized) {
//                uploadWorkoutToCloud()
//            }
//
//            Button(Strings.cancelButton.localized, role: .cancel) { }
//        } message: {
//            Text(.uploadWorkoutMessage)
//        }
    }

    /// Button that removes the workout from iCloud.
    var removeWorkoutFromCloudToolbarButton: some View {
        Button {
//            showingRemoveWorkoutFromCloudAlert = true
            removeWorkoutFromCloud(deleteLocal: false)

        } label: {
            Label(Strings.removeWorkout.localized, systemImage: "icloud.slash")
        }
//        .alert(Strings.removeWorkout.localized,
//               isPresented: $showingRemoveWorkoutFromCloudAlert) {
//            Button(Strings.removeButton.localized) {
//                removeWorkoutFromCloud(deleteLocal: false)
//            }
//
//            Button(Strings.cancelButton.localized, role: .cancel) { }
//        } message: {
//            Text(.removeWorkoutMessage)
//        }
    }

    /// Computed property to get the text displayed in the section header for the workout date.
    var workoutDateSectionHeader: Text {
        workout.completed ? Text(.completedSectionHeader) : Text(.scheduledSectionHeader)
    }

    /// Computed property to get the date string of the workout formatted to omit the time component but show the date
    /// in full.
    var dateString: String {
        workout.workoutDate.formatted(date: .complete, time: .omitted)
    }

    /// Button that presents a confirmation dialog enabling the user to schedule a workout for up to 7 days in advance.
    var workoutDateButton: some View {
        Button {
            showingDateConfirmationDialog = true
            hideKeyboard()
        } label: {
            Text(workout.workoutDate.formatted(date: .complete, time: .omitted))
        }
        .accessibilityIdentifier("Workout date")
        .confirmationDialog(Strings.selectWorkoutDateLabel.localized,
                            isPresented: $showingDateConfirmationDialog) {
            WorkoutDateConfirmationDialog(workout: workout)
        } message: {
            Text(.selectWorkoutDateMessage)
        }
    }

    /// Boolean value indicating whether a full swipe is permitted for the exercise row view.
    var allowsFullSwipe: Bool {
        return (workout.template || workout.workoutExerciseSets.filter({ !$0.completed }).isEmpty) ? true : false
    }

    /// The list of exercises contained in the workout, as well as a button to add additional exercises.
    var workoutExerciseList: some View {
        List {
            ForEach(exercises, id: \.self) { exercise in
                EditWorkoutExerciseListView(workout: workout,
                                            exercise: exercise)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            withAnimation {
                                dataController.removeExercise(exercise, fromWorkout: workout)
                                exercises.removeAll(where: { $0.exerciseId == exercise.exerciseId })
                                save()
                            }
                        } label: {
                            Label(Strings.deleteButton.localized, systemImage: "trash")
                                .labelStyle(.titleAndIcon)
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: allowsFullSwipe) {
                        Button {
                            dataController.addSet(toExercise: exercise, inWorkout: workout)
                            update()
                            save()
                        } label: {
                            Label(Strings.addSet.localized, systemImage: "plus.circle")
                                .labelStyle(.titleAndIcon)
                        }
                        .tint(.blue)

                        if !allowsFullSwipe {
                            Button {
                                withAnimation {
                                    dataController.completeNextSet(forExercise: exercise, inWorkout: workout)
                                    update()
                                    save()
                                }
                            } label: {
                                Label(Strings.completeNextSetButton.localized, systemImage: "checkmark.circle")
                                    .labelStyle(.titleAndIcon)
                            }
                            .tint(.green)
                        }
                    }
            }
            .onDelete(perform: removeExerciseFromWorkout)
            .onMove(perform: reorderExercises)

            // Button to add a new exercise to the workout.
            Button {
                withAnimation {
                    showingAddExerciseSheet = true
                }
            } label: {
                Label(Strings.addExercise.localized, systemImage: "plus")
            }
            .sheet(isPresented: $showingAddExerciseSheet, onDismiss: setExercisesArray) {
                AddExerciseToWorkoutView(workout: workout)
            }
        }
    }

    /// Button enabling the user to create a template from a workout.
    var createTemplateFromWorkoutButton: some View {
        Button(Strings.createTemplateFromWorkoutButton.localized) {
            showingCreateTemplateConfirmation = true
        }
        .alert(Strings.createTemplateConfirmationTitle.localized,
               isPresented: $showingCreateTemplateConfirmation) {
            Button(Strings.confirmButton.localized) {
                dataController.createNewWorkoutOrTemplateFromExisting(workout,
                                                                      isTemplate: true)
            }

            Button(Strings.cancelButton.localized, role: .cancel) { }
        } message: {
            Text(.createTemplateConfirmationMessage)
        }
    }

    /// Button enabling the user to create a workout from a template.
    var createWorkoutFromTemplateButton: some View {
        Button(Strings.createWorkoutFromTemplateButton.localized) {
            showingCreateWorkoutConfirmation = true
        }
        .alert(Strings.createWorkoutConfirmationTitle.localized,
               isPresented: $showingCreateWorkoutConfirmation) {
            Button(Strings.confirmButton.localized) {
                showingDateConfirmationDialog = true
            }

            Button(Strings.cancelButton.localized, role: .cancel) { }
        } message: {
            Text(.createWorkoutConfirmationMessage)
        }
        .confirmationDialog(Strings.scheduleWorkout.localized,
                            isPresented: $showingDateConfirmationDialog) {
            WorkoutDateConfirmationDialog(workout: workout)
        } message: {
            Text(.selectWorkoutDateMessage)
        }
    }

    var completeWorkoutButtonCopy: LocalizedStringKey {
        return workout.completed
        ? Strings.markWorkoutIncomplete.localized
        : Strings.completeWorkout.localized
    }

    var completeWorkoutButton: some View {
        Button(completeWorkoutButtonCopy) {
            showingCompleteConfirmation = true
        }
        .alert(workout.getConfirmationAlertTitle(workout: workout),
               isPresented: $showingCompleteConfirmation) {
            Button(Strings.confirmButton.localized, action: toggleCompletionStatus)

            Button(Strings.cancelButton.localized, role: .cancel, action: { })
        } message: {
            Text(workout.getConfirmationAlertMessage(workout: workout))
        }
    }

    /// Button to delete the workout.
    var deleteWorkoutButton: some View {
        Button(deleteWorkoutTemplateButtonText, role: .destructive) {
            showingDeleteWorkoutConfirmation = true

            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
        .alert(Strings.areYouSureAlertTitle.localized,
               isPresented: $showingDeleteWorkoutConfirmation) {
            Button(Strings.deleteButton.localized, role: .destructive) {
                if cloudStatus == .exists {
                    removeWorkoutFromCloud(deleteLocal: true)
                } else {
                    dataController.delete(workout)
                }

                remindUser = false
                update()
                dismiss()
            }

            Button(Strings.cancelButton.localized, role: .cancel) { }
        } message: {
            deleteWorkoutTemplateAlertMessage
        }
    }

    /// Computed property to get text displayed on the button for deleting a workout.
    var deleteWorkoutTemplateButtonText: LocalizedStringKey {
        workout.template ? Strings.deleteTemplateButton.localized : Strings.deleteWorkoutButton.localized
    }

    /// Computed property to get the text displayed in the alert message shown when deleting a workout.
    var deleteWorkoutTemplateAlertMessage: Text {
        workout.template ? Text(.deleteTemplateConfirmationMessage) : Text(.deleteWorkoutConfirmationMessage)
    }

    var body: some View {
        Form {
            Section(header: workout.template ? Text(.templateName) : Text(.workoutName)) {
                TextField(Strings.workoutName.localized,
                          text: $name.onChange(update))
                .focused($isWorkoutNameFocused)
                .clearTextFieldButton(isActive: _isWorkoutNameFocused, text: $name.onChange(update))
            }

            if !workout.template {
                Section(header: workoutDateSectionHeader) {
                    workoutDateButton
                }
                .accessibilityIdentifier("Workout Date")
            }

            if !workout.template && !workout.completed {
                Section(header: Text(.workoutReminderTimeSectionHeader)) {
                    Toggle(Strings.showReminders.localized, isOn: $remindUser.animation().onChange {
                        update()
                        hideKeyboard()
                    })
                    .alert(isPresented: $showingNotificationsAlert) {
                        Alert(
                            title: Text(.oops),
                            message: Text(.enableNotificationsError),
                            primaryButton: .default(Text(.settings), action: showingAppNotificationsSettings),
                            secondaryButton: .cancel()
                        )
                    }

                    if remindUser {
                        DatePicker(
                            Strings.reminderTime.localized,
                            selection: $reminderTime.onChange(update),
                            displayedComponents: .hourAndMinute
                        )
                    }
                }
            }

            Section(header: Text(.exercisesTab)) {
                workoutExerciseList
            }

            if !workout.template {
                Section {
                    createTemplateFromWorkoutButton
                }
                .sectionButton()
                .background(Color.blue)

                Section {
                    completeWorkoutButton
                }
                .sectionButton()
                .background(workout.completed ? Color.orange : Color.green)
            } else {
                Section {
                    createWorkoutFromTemplateButton
                }
                .sectionButton()
                .background(Color.blue)
            }

            Section {
                deleteWorkoutButton
            }
            .sectionButton()
            .background(Color.red)
        }
        .sheet(isPresented: $showingSignInWithAppleSheet) {
            SignInView(showingOnboardingJourney: $showingOnboardingJourney)
        }
        .navigationTitle(navigationTitle)
        .toolbar {
            keyboardDoneButton

            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if !exercises.isEmpty {
                    EditButton()

                    switch cloudStatus {
                    case .checking:
                        ProgressView()
                    case .exists:
                        removeWorkoutFromCloudToolbarButton
                    case .absent:
                        uploadWorkoutToCloudToolbarButton
                    }
                }
            }
        }
        .onAppear {
            setExercisesArray()
            updateCloudStatus()

            UIScrollView.appearance().keyboardDismissMode = .onDrag
        }
        .onDisappear {
            update()
            save()
        }
    }

    /// Uploads the workout to iCloud
    func uploadWorkoutToCloud() {
        if let username = username {
            let records = workout.prepareCloudRecords(owner: username)
            let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
            operation.savePolicy = .allKeys

            operation.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    print("Success.")
                case .failure(let error):
                    cloudError = error.getCloudKitError()
                }

                updateCloudStatus()
            }

            cloudStatus = .checking
            CKContainer.default().publicCloudDatabase.add(operation)
        } else {
            showingSignInWithAppleSheet = true
        }
    }

    /// Updates the cloud status property depending on the whether the workout is currently stored in CloudKit or not.
    func updateCloudStatus() {
        workout.checkCloudStatus { exists in
            if exists {
                cloudStatus = .exists
            } else {
                cloudStatus = .absent
            }
        }
    }

    /// Removes a workout from CloudKit storage.
    func removeWorkoutFromCloud(deleteLocal: Bool) {
        let name = workout.objectID.uriRepresentation().absoluteString
        let id = CKRecord.ID(recordName: name)

        let operation = CKModifyRecordsOperation(recordsToSave: nil,
                                                 recordIDsToDelete: [id])

        operation.modifyRecordsResultBlock = { result in
            switch result {
            case .success:
                if deleteLocal {
                    dataController.delete(workout)
                }
            case .failure(let error):
                cloudError = error.getCloudKitError()
            }

            updateCloudStatus()
        }

        cloudStatus = .checking
        CKContainer.default().publicCloudDatabase.add(operation)
    }

    /// Sets the exercises array used to construct this view.
    func setExercisesArray() {
        exercises = workout.workoutExercises.sorted { first, second in
            let firstIndex = dataController.getPlacement(forExercise: first, inWorkout: workout)
            let secondIndex = dataController.getPlacement(forExercise: second, inWorkout: workout)

            if  firstIndex ?? 0 < secondIndex ?? 0 {
                return true
            } else {
                return false
            }
        }
    }

    /// Enables users to drag rows in the list of exercises to reorder them.
    /// - Parameters:
    ///   - source: The original placement of the row being moved in the exercises array.
    ///   - destination: The new placement of the row being moved in the exercises array.
    func reorderExercises(from source: IndexSet, to destination: Int) {
        exercises.move(fromOffsets: source, toOffset: destination)
        dataController.updateOrderOfExercises(toMatch: exercises, forWorkout: workout)
    }

    /// Responsible for toggling the completion status of the workout and generating haptic feedback.
    func toggleCompletionStatus() {
        workout.completed.toggle()

        workout.workoutExerciseSets.forEach {
            $0.completed = true
        }

        save()

        if workout.completed {
            remindUser = false

            do {
                try engine?.start()

                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)

                let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
                let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 0)

                let parameterCurve = CHHapticParameterCurve(
                    parameterID: .hapticIntensityControl,
                    controlPoints: [start, end],
                    relativeTime: 0
                )

                let transientEvent = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: 0
                )

                let continuousEvent = CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [intensity, sharpness],
                    relativeTime: 0.125,
                    duration: 1
                )

                let pattern = try CHHapticPattern(
                    events: [transientEvent, continuousEvent],
                    parameterCurves: [parameterCurve])

                let player = try engine?.makePlayer(with: pattern)
                try player?.start(atTime: 0)
            } catch {
                // Playing haptics didn't work, but that's ok.
            }
        }
    }

    /// Removes an exercise from a workout using its position in the list displayed to the user.
    ///
    /// Should only be used within this view in the onDelete modifier for the workout list. The swipe action delete
    /// button uses a DataController method to remove the exercise from the workout.
    /// - Parameters:
    ///   - offsets: The position of the exercise in the list displayed to the user.
    ///   - workout: The workout from which the exercise should be deleted.
    func removeExerciseFromWorkout(at offsets: IndexSet) {
        exercises.remove(atOffsets: offsets)

        if let offset = offsets.first {
            let exerciseToRemove = exercises[offset]
            dataController.removeExercise(exerciseToRemove, fromWorkout: workout)
            save()
        }
    }

    /// Synchronise the @State properties of the view with their Core Data equivalents in whichever Workout
    /// object is being edited.
    ///
    /// Changes will be announced to any property wrappers observing the workout.
    func update() {
        workout.objectWillChange.send()

        workout.name = name
        workout.setValue(NSSet(array: exercises), forKey: "exercises")

        if remindUser {
            var dateComponents = DateComponents()
            let dateScheduled = Calendar.current.dateComponents([.year, .month, .day],
                                                                from: workout.workoutDate)
            let reminderTimeSet = Calendar.current.dateComponents([.hour, .minute],
                                                                  from: reminderTime)

            dateComponents.year = dateScheduled.year
            dateComponents.month = dateScheduled.month
            dateComponents.day = dateScheduled.day
            dateComponents.hour = reminderTimeSet.hour
            dateComponents.minute = reminderTimeSet.minute

            workout.reminderTime = Calendar.current.date(from: dateComponents)

            dataController.addReminders(for: workout) { success in
                if success == false {
                    workout.reminderTime = nil
                    remindUser = false

                    showingNotificationsAlert = true
                }
            }
        } else {
            workout.reminderTime = nil
            dataController.removeReminders(for: workout)
        }
    }

    func save() {
        dataController.updateWorkout(workout)
    }

    func showingAppNotificationsSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

struct EditWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        EditWorkoutView(workout: Workout.example)
    }
// swiftlint:disable:next file_length
}
