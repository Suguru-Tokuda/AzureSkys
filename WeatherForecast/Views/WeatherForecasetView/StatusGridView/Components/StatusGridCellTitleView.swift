//
//  StatusGridCellTitleView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/13/23.
//

import SwiftUI

struct StatusGridCellTitleView: View {
    var icon: String
    var title: String

    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title.uppercased())
        }
            .withStatusGridViewLabelModifier()
    }
}

#Preview {
    StatusGridCellTitleView(
        icon: "thermometer.medium",
        title: "Feels Like"
    )
    .preferredColorScheme(.dark)
}
