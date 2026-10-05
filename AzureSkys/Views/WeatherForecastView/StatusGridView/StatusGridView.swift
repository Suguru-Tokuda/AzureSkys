//
//  StatusGridView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/13/23.
//

import SwiftUI

struct StatusGridView: View {
    @AppStorage(UserDefaultKeys.tempScale.rawValue) var tempScale: TempScale = .fahrenheit
    var forecast: Forecast
    var background: LinearGradient
    var parentViewWidth: CGFloat
    let columns = Array(repeating: GridItem(), count: 2)
    
    var body: some View {
        let width: CGFloat = parentViewWidth / CGFloat(columns.count) * 0.85

        LazyVGrid(columns: columns, spacing: 15) {
            WindStatusGridViewCell(
                width: width,
                background: background,
                wind: Wind(speed: forecast.windSpeed, 
                            gust: forecast.windGust,
                            deg: forecast.windDeg))
            
            StatusGridCellView(
                width: width,
                background: background,
                icon: SystemImages.thermometerMedium.rawValue,
                title: Strings.feelsLike.rawValue,
                value: forecast.feelsLike.getDegree(tempScale: tempScale).formatDouble(maxFractions: 0).appendDegree())
            
            if let visibility = forecast.visibility {
                StatusGridCellView(
                    width: width,
                    background: background,
                    icon: SystemImages.eyeFill.rawValue,
                    title: Strings.visibility.rawValue,
                    value: Strings.miles(String(describing: visibility.toMiles())))
            }
            
            if let humidity = forecast.humidity {
                StatusGridCellView(
                    width: width,
                    background: background,
                    icon: SystemImages.humidityFill.rawValue,
                    title: Strings.humidity.rawValue,
                    value: Strings.humidityValue(String(describing: humidity)))
            }
            
            if let pressure = forecast.pressure {
                StatusGridCellView(
                    width: width,
                    background: background,
                    icon: SystemImages.gaugeWithDotsNeedle50Percent.rawValue,
                    title: Strings.pressure.rawValue,
                    value: Strings.pressureValue(String(describing: pressure)))
            }
            
            if let clouds = forecast.clouds {
                StatusGridCellView(
                    width: width,
                    background: background,
                    icon: SystemImages.cloudFill.rawValue,
                    title: Strings.cloudiness.rawValue,
                    value: Strings.percentage(String(describing: clouds)))
            }
            
            if let uvi = forecast.uvi {
                StatusGridCellView(
                    width: width,
                    background: background,
                    icon: SystemImages.sunMax.rawValue,
                    title: Strings.uvIndex.rawValue,
                    value: String(describing: uvi))
            }
            
            if let dewPoint = forecast.dewPoint {
                StatusGridCellView(
                    width: width,
                    background: background,
                    icon: SystemImages.dropFill.rawValue,
                    title: Strings.dewPoint.rawValue,
                    value: dewPoint.getDegree(tempScale: tempScale).formatDouble(maxFractions: 0).appendDegree())

            }
        }
    }
}

#Preview {
    StatusGridView(
        forecast: PreviewManager.oneCallResponse.current,
        background: Color.skyBlue100,
        parentViewWidth: 430
    )
    .preferredColorScheme(.dark)
}
