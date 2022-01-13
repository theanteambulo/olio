//
//  SectionFooterErrorMessage.swift
//  Olio
//
//  Created by Jake King on 12/01/2022.
//

import SwiftUI

struct SectionFooterErrorMessage: View {
    /// The exercise set error used to construct this view.
    @Binding var exerciseSetError: ExerciseSetError?

    /// Boolean to indicate whether the exercise set is a stretch or not.
    var exerciseSetStretch: Bool = false

    var errorMessage: Text {
        switch exerciseSetError {
        case .reps:
            return Text(.repLimitError)
        case .weight:
            return Text(.weightLimitError)
        case .repsAndWeight:
            return Text(.repAndWeightLimitError)
        case .distance:
            return Text(.distanceLimitError)
        case .duration:
            if exerciseSetStretch {
                return Text(.secsDurationLimitError)
            } else {
                return Text(.minsDurationLimitError)
            }
        case .distanceAndDuration:
            return Text(.distanceAndDurationLimitError)
        default:
            return Text("")
        }
    }

    var body: some View {
        HStack {
            Spacer()

            Group {
                Image(systemName: "exclamationmark.circle")

                errorMessage
            }
            .foregroundColor(exerciseSetError != nil ? .red : .clear)
        }
    }
}

struct SectionFooterErrorMessage_Previews: PreviewProvider {
    static var previews: some View {
        SectionFooterErrorMessage(exerciseSetError: .constant(.reps))
    }
}
