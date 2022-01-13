//
//  AddOlioLibraryView.swift
//  Olio
//
//  Created by Jake King on 13/01/2022.
//

import SwiftUI

/// A single row in the list of all exercises representing a given exercise.
struct AddOlioLibraryView: View {
    /// The environment singleton responsible for managing the Core Data stack.
    @EnvironmentObject var dataController: DataController

    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                Text(.noExercisesYetTitle)
                    .font(.headline)
                    .padding(.vertical)

                Text(.noExercisesYetMessage)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack {
                    Button {
                        dataController.loadExerciseLibrary()
                        dataController.save()
                    } label: {
                        HStack {
                            Spacer()

                            Text(.loadOlioExercises)

                            Spacer()
                        }
                    }
                }
                .frame(minHeight: 44)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .contentShape(Rectangle())
                .padding()
            }
        }
    }
}

struct AddOlioLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        AddOlioLibraryView()
    }
}
