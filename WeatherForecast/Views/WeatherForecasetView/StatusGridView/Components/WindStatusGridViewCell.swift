//
//  WindStatusGridViewCell.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/11/23.
//

import SwiftUI

struct WindStatusGridViewCell: View {
    var width: CGFloat
    var background: LinearGradient
    var wind: Wind
    
    var body: some View {
        ZStack {
            StatusGridViewCellContainer(
                width: width,
                background: background) {
                    VStack {
                        StatusGridCellTitleView(icon: "wind", title: "Wind")
                        HStack {
                            Text("\(wind.speed, specifier: "%.0f")")
                                .withStatusGridViewValueLabelModifier()
                            VStack(alignment: .leading) {
                                Text("MPH")
                                    .withStatusGridViewLabelModifier()
                                Text("Wind")
                                    .font(.callout.weight(.semibold))
                            }
                            Spacer()
                        }
                        .padding(.top, 5)
                        .padding(.bottom, 1)
                        if let gust = wind.gust {
                            Divider()
                                .frame(height: 0.8)
                                .background(.white.opacity(0.8))
                            HStack {
                                Text("\(gust, specifier: "%.0f")")
                                    .withStatusGridViewValueLabelModifier()
                                VStack(alignment: .leading) {
                                    Text("MPH")
                                        .withStatusGridViewLabelModifier()
                                    Text("Gusts")
                                        .font(.callout.weight(.semibold))
                                }
                                Spacer()
                            }
                            .padding(.top, 1)
                        } else {
                            Spacer()
                        }
                    }
                }
        }
    }
}

#Preview {
    WindStatusGridViewCell(
        width: 150,
        background: Color.skyBlue,
        wind: PreviewManager.weatherForecastData.list[0].wind!
    )
    .preferredColorScheme(.dark)
}
