//
//  StatusListCell.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/5/26.
//

import SwiftUI

struct StatusListCell: View {
    let iconName: String
    let iconBackgroundColor: Color
    let topLabel: String?
    let parameterString: String?
    let footnoteString: String?

    init(
        iconName: String,
        iconBackgroundColor: Color,
        topLabel: String?,
        parameterString: String?,
        footnoteString: String?
    ) {
        self.iconName = iconName
        self.iconBackgroundColor = iconBackgroundColor
        self.topLabel = topLabel
        self.parameterString = parameterString
        self.footnoteString = footnoteString
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: iconName)
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(iconBackgroundColor)
                .frame(height: 20, alignment: .leading)
                .padding(.bottom, 4)

            if let topLabel {
                Text(topLabel)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            if let parameterString {
                Text(parameterString)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
            }
            if let footnoteString {
                Text(footnoteString)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 100, maxHeight: .infinity, alignment: .topLeading)
        .padding(20)
        .modifier(WeatherPanelModifier())
        .accessibilityElement(children: .combine)
    }
}

#Preview("Humidity") {
    StatusListCell(
        iconName: SystemImages.humidityFill.rawValue,
        iconBackgroundColor: .cyan,
        topLabel: "Humidity",
        parameterString: "42%",
        footnoteString: "Comfortable"
    )
    .frame(width: 160)
    .preferredColorScheme(.dark)
}
