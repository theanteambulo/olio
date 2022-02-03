//
//  ExerciseSetCompletionIcon.swift
//  Olio
//
//  Created by Jake King on 04/01/2022.
//

import SwiftUI

struct ExerciseSetCompletionIcon: View {
    /// The exercise set used to construct this view.
    @ObservedObject var exerciseSet: ExerciseSet

    init(exerciseSet: ExerciseSet) {
        self.exerciseSet = exerciseSet
    }

    /// Computed string representing the name of the icon that should be displayed.
    var completionIcon: String {
        exerciseSet.completed
        ? "checkmark.circle.fill"
        : "circle"
    }

    /// Computed string representing the colour of the icon that should be displayed.
    var iconColor: Color {
        exerciseSet.completed
        ? .green
        : .red
    }

    /// The accessibility label of the icon displayed.
    var iconAccessibilityLabel: Text {
        exerciseSet.completed
        ? Text("Mark set incomplete")
        : Text("Mark set complete")
    }

    var body: some View {
        VStack(alignment: .leading) {
            if !(exerciseSet.workout?.template ?? true) {
                Image(systemName: completionIcon)
                    .frame(width: 25)
                    .padding(.trailing, 10)
                    .foregroundColor(iconColor)
                    .onTapGesture {
                        withAnimation {
                            exerciseSet.completed.toggle()
                            update()
                        }
                    }
                    .accessibilityLabel(iconAccessibilityLabel)
                    .accessibilityAddTraits(.isButton)
            }
        }
    }

    /// Synchronise the @State properties of the view with their Core Data equivalents in whichever ExerciseSet
    /// object is being edited.
    ///
    /// Changes will be announced to any property wrappers observing the exercise set.
    func update() {
        exerciseSet.objectWillChange.send()
        exerciseSet.exercise?.objectWillChange.send()
        exerciseSet.workout?.objectWillChange.send()
    }
}

struct ExerciseSetCompletionIcon_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseSetCompletionIcon(exerciseSet: ExerciseSet.example)
    }
}
