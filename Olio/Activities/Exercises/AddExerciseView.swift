//
//  AddExerciseView.swift
//  Olio
//
//  Created by Jake King on 25/11/2021.
//

import SwiftUI

struct AddExerciseView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var bodyweight = true
    @State private var muscleGroup = 1

    var saveToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Save") {
                save()
                dismiss()
            }
        }
    }

    var dismissNoSaveToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                dismiss()
            } label: {
                Label("Dismiss", systemImage: "xmark")
            }
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Settings")) {
                    TextField("Exercise name", text: $name)

                    Picker("Muscle Group", selection: $muscleGroup) {
                        Text("Chest").tag(1)
                        Text("Back").tag(2)
                        Text("Shoulders").tag(3)
                        Text("Biceps").tag(4)
                        Text("Triceps").tag(5)
                        Text("Legs").tag(6)
                        Text("Abs").tag(7)
                    }

                    Toggle("Bodyweight exercise", isOn: $bodyweight)
                }
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                saveToolbarItem
                dismissNoSaveToolbarItem
            }
        }
    }

    func save() {
        let exercise = Exercise(context: managedObjectContext)
        exercise.name = name
        exercise.muscleGroup = Int16(muscleGroup)
        exercise.bodyweight = bodyweight

        dataController.save()
    }
}

struct AddExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        AddExerciseView()
    }
}
