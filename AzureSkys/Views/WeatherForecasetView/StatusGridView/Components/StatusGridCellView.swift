//
//  StatusGridCellView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/11/23.
//

import SwiftUI

struct StatusGridCellView: View {
    var width: CGFloat
    var background: LinearGradient
    var icon: String
    var title: String
    var value: String
    
    var body: some View {
        StatusGridViewCellContainer(width: width, background: background) {
            VStack {
                StatusGridCellTitleView(icon: icon, title: title)
                Text(value)
                    .withStatusGridViewValueLabelModifier()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 5)
                Spacer()
            }
        }
    }
}

#Preview {
    StatusGridCellView(
        width: 150.0,
        background: Color.skyBlue,
        icon: "thermometer.medium",
        title: "FEELS LIKE",
        value: "44°"
    )
    .preferredColorScheme(.dark)
}
