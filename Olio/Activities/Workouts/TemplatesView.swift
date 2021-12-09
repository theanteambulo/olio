//
//  TemplatesView.swift
//  Olio
//
//  Created by Jake King on 09/12/2021.
//

import SwiftUI

struct TemplatesView: View {
    @StateObject var viewModel: ViewModel

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var rows: [GridItem] {
        [GridItem(.fixed(100))]
    }

    var body: some View {
        Group {
            Text(.workoutTemplates)
                .padding(.leading)
                .font(.title3)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: rows) {
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
