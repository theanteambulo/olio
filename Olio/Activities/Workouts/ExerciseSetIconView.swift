//
//  ExerciseSetIconView.swift
//  Olio
//
//  Created by Jake King on 27/11/2021.
//

import SwiftUI

struct ExerciseSetIconView: View {
    let completed: Bool

    var body: some View {
        Image(systemName: "tortoise.fill")
            .foregroundColor(completed ? .green : .red)
    }
}
