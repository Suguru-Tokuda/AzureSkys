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
                title: WeatherStrings.feelsLike,
                value: forecast.feelsLike.getDegree(tempScale: tempScale).formatDouble(maxFractions: 0).appendDegree())
            
            if let visibility = forecast.visibility {
                StatusGridCellView(
                    width: width,
                    background: background,
                    icon: SystemImages.eyeFill.rawValue,
                    title: WeatherStrings.visibility,
                    value: WeatherFormatting.miles(String(describing: visibility.toMiles())))
            }
            
            if let humidity = forecast.humidity {
                StatusGridCellView(
                    width: width,
                    background: background,
                    icon: SystemImages.humidityFill.rawValue,
                    title: WeatherStrings.humidity,
                    value: WeatherFormatting.humidityValue(String(describing: humidity)))
            }
            
            if let pressure = forecast.pressure {
                StatusGridCellView(
                    width: width,
                    background: background,
                    icon: SystemImages.gaugeWithDotsNeedle50Percent.rawValue,
                    title: WeatherStrings.pressure,
                    value: WeatherFormatting.pressureValue(String(describing: pressure)))
            }
            
            if let clouds = forecast.clouds {
                StatusGridCellView(
                    width: width,
                    background: background,
                    icon: SystemImages.cloudFill.rawValue,
                    title: WeatherStrings.cloudiness,
                    value: WeatherFormatting.percentage(String(describing: clouds)))
            }
            
            if let uvi = forecast.uvi {
                StatusGridCellView(
                    width: width,
                    background: background,
                    icon: SystemImages.sunMax.rawValue,
                    title: WeatherStrings.uvIndex,
                    value: String(describing: uvi))
            }
            
            if let dewPoint = forecast.dewPoint {
                StatusGridCellView(
                    width: width,
                    background: background,
                    icon: SystemImages.dropFill.rawValue,
                    title: WeatherStrings.dewPoint,
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
