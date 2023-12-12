//
//  StatusGridCellView.swift
//  WeatherForecast
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
                HStack {
                    Image(systemName: icon)
                    Text(title)
                }
                    .font(.footnote.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.white.opacity(0.5))
                Text(value)
                    .font(.system(size: 40).weight(.regular))
                    .frame(maxWidth: .infinity, alignment: .leading)
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
