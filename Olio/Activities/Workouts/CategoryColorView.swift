//
//  CategoryColorView.swift
//  Olio
//
//  Created by Jake King on 02/01/2022.
//

import SwiftUI

struct CategoryColorView: View {
    /// The array of colours used to construct this view.
    private var colors: [Color]

    init(colors: [Color]) {
        self.colors = colors
    }

    var rows: [GridItem] {
        [GridItem()]
    }

    var body: some View {
        LazyHGrid(rows: rows) {
            ForEach(colors, id: \.self) { exerciseCategoryColor in
                Circle()
                    .frame(width: 7)
                    .foregroundColor(exerciseCategoryColor)
            }
        }
    }
}

struct CategoryColorView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryColorView(colors: [.red])
    }
}
