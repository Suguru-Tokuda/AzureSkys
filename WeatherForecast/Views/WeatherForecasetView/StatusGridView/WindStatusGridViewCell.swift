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
}
