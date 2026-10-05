//
//  WindStatusGridViewCell.swift
//  AzureSkys
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
                        StatusGridCellTitleView(icon: SystemImages.wind.rawValue, title: Strings.wind.rawValue)
                        HStack {
                            Text(String(format: Strings.wholeNumberFormat.rawValue, wind.speed))
                                .withStatusGridViewValueLabelModifier()
                            VStack(alignment: .leading) {
                                Text(Strings.mph.rawValue)
                                    .withStatusGridViewLabelModifier()
                                Text(Strings.wind.rawValue)
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
                                Text(String(format: Strings.wholeNumberFormat.rawValue, gust))
                                    .withStatusGridViewValueLabelModifier()
                                VStack(alignment: .leading) {
                                    Text(Strings.mph.rawValue)
                                        .withStatusGridViewLabelModifier()
                                    Text(Strings.gusts.rawValue)
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
        background: Color.skyBlue100,
        wind: PreviewManager.weatherForecastData.list[0].wind!
    )
    .preferredColorScheme(.dark)
}
