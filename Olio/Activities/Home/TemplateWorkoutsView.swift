//
//  TemplateWorkoutsView.swift
//  Olio
//
//  Created by Jake King on 25/11/2021.
//

import SwiftUI

struct TemplateWorkoutsView: View {
    let templateWorkouts: FetchedResults<Workout>

    var workoutRows: [GridItem] {
        [GridItem(.fixed(100))]
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: workoutRows) {
                ForEach(templateWorkouts) { workout in
                    VStack(alignment: .leading) {
                        Text("\(workout.workoutExercises.count) exercises")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(workout.workoutName)
                            .font(.title3)
                    }
                    .padding()
                    .background(Color.secondarySystemGroupedBackground)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 5)
                }
            }
        }
    }
}
