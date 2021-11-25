//
//  AddExerciseView.swift
//  Olio
//
//  Created by Jake King on 25/11/2021.
//

import SwiftUI

struct AddExerciseView: View {
    @EnvironmentObject var dataController: DataController

    @State private var name = ""
    @State private var bodyweight = true
    @State private var muscleGroup = 1

    var body: some View {
        NavigationView {
            Form {
//                Section(header: Text())
            }
        }
    }
}

struct AddExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        AddExerciseView()
    }
}
