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
                    TemplateWorkoutCardView(workout: workout)
                }
            }
        }
    }
}
