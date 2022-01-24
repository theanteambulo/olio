//
//  TemplatesView.swift
//  Olio
//
//  Created by Jake King on 09/12/2021.
//

import SwiftUI

/// A horizontal scroll view containing tappable cards with details of each template.
struct TemplatesView: View {
    /// The presentation model representing the state of this view capable of reading model data and carrying out all
    /// transformations needed to prepare that data for presentation.
    @StateObject var viewModel: ViewModel

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    /// A grid with a single row 80 points in size.
    var rows: [GridItem] {
        [GridItem(.fixed(85))]
    }

    var body: some View {
        Group {
            Text(.workoutTemplates)
                .padding(.leading)
                .font(.title3)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: rows) {
                    Button {
                         viewModel.addTemplate()
                    } label: {
                        VStack(alignment: .center) {
                            Image(systemName: "plus")
                                .padding(.bottom, 5)

                            Text(.addNewTemplate)
                        }
                    }
                    .accessibilityIdentifier("Add new template")
                    .padding(10)
                    .frame(maxHeight: .infinity)
                    .background(Color.secondarySystemGroupedBackground)
                    .cornerRadius(5)
                    .shadow(color: Color.black.opacity(0.2),
                            radius: 5)

                    ForEach(viewModel.templates) { template in
                        TemplateCardView(template: template)
                    }
                }
                .padding(.horizontal)
                .fixedSize(horizontal: false,
                           vertical: true)
            }
            .padding(.bottom)

            Text(.workoutsScheduled)
                .padding(.leading)
                .font(.title3)
        }
    }
}

struct TemplatesView_Previews: PreviewProvider {
    static var previews: some View {
        TemplatesView(dataController: DataController.preview)
    }
}
