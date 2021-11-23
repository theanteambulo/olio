//
//  ExercisesView.swift
//  Olio
//
//  Created by Jake King on 23/11/2021.
//

import SwiftUI

struct ExercisesView: View {
    let exercises: FetchRequest<Exercise>

    static let tag: String? = "Exercises"

    init() {
        exercises = FetchRequest<Exercise>(
            entity: Exercise.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.muscleGroup, ascending: true)]
        )
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(exercises.wrappedValue) { exercise in
                    Text(exercise.exerciseName)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Exercises")
        }
    }
}

struct ExercisesView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        ExercisesView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
